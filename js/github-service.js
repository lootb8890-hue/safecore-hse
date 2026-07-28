/**
 * SafeCore HSE - GitHub Data Service
 * Handles all CRUD operations via GitHub REST API
 * Data is stored as JSON files in a GitHub repository
 */

class GitHubService {
    constructor() {
        this.token = localStorage.getItem('gh_token') || '';
        this.owner = localStorage.getItem('gh_owner') || '';
        this.repo = localStorage.getItem('gh_repo') || '';
        this.branch = localStorage.getItem('gh_branch') || 'main';
        this.baseUrl = 'https://api.github.com';
        this._shaCache = {}; // cache file SHAs for updates
    }

    // ===== CONNECTION =====
    isConfigured() {
        return !!(this.token && this.owner && this.repo);
    }

    configure(token, owner, repo, branch = 'main') {
        this.token = token;
        this.owner = owner;
        this.repo = repo;
        this.branch = branch;
        localStorage.setItem('gh_token', token);
        localStorage.setItem('gh_owner', owner);
        localStorage.setItem('gh_repo', repo);
        localStorage.setItem('gh_branch', branch);
    }

    disconnect() {
        this.token = '';
        this.owner = '';
        this.repo = '';
        localStorage.removeItem('gh_token');
        localStorage.removeItem('gh_owner');
        localStorage.removeItem('gh_repo');
        localStorage.removeItem('gh_branch');
        this._shaCache = {};
    }

    // ===== API HELPERS =====
    _headers() {
        return {
            'Authorization': `Bearer ${this.token}`,
            'Accept': 'application/vnd.github.v3+json',
            'Content-Type': 'application/json',
            'X-GitHub-Api-Version': '2022-11-28'
        };
    }

    async _request(method, endpoint, body = null) {
        const url = `${this.baseUrl}${endpoint}`;
        const options = { method, headers: this._headers() };
        if (body) options.body = JSON.stringify(body);

        const response = await fetch(url, options);
        if (!response.ok) {
            const err = await response.json().catch(() => ({}));
            throw new Error(`GitHub API Error ${response.status}: ${err.message || response.statusText}`);
        }
        return response.json();
    }

    // ===== TEST CONNECTION =====
    async testConnection() {
        try {
            const user = await this._request('GET', '/user');
            // Also verify repo access
            await this._request('GET', `/repos/${this.owner}/${this.repo}`);
            return { success: true, user: user.login, avatar: user.avatar_url };
        } catch (e) {
            return { success: false, error: e.message };
        }
    }

    // ===== READ FILE =====
    async readFile(path) {
        try {
            const data = await this._request('GET',
                `/repos/${this.owner}/${this.repo}/contents/data/${path}?ref=${this.branch}`
            );
            this._shaCache[path] = data.sha;
            const content = atob(data.content.replace(/\n/g, ''));
            // Handle UTF-8 properly
            const bytes = new Uint8Array([...content].map(c => c.charCodeAt(0)));
            const decoded = new TextDecoder('utf-8').decode(bytes);
            return JSON.parse(decoded);
        } catch (e) {
            console.warn(`Could not read ${path}:`, e.message);
            return null;
        }
    }

    // ===== WRITE FILE =====
    async writeFile(path, data, message = '') {
        const jsonStr = JSON.stringify(data, null, 2);
        // Encode UTF-8 properly
        const encoder = new TextEncoder();
        const bytes = encoder.encode(jsonStr);
        let binary = '';
        bytes.forEach(b => binary += String.fromCharCode(b));
        const content = btoa(binary);

        const commitMessage = message || `تحديث ${path} - ${new Date().toLocaleString('ar-SA')}`;

        const body = {
            message: commitMessage,
            content: content,
            branch: this.branch
        };

        // If we have a cached SHA, include it (required for updates)
        if (this._shaCache[path]) {
            body.sha = this._shaCache[path];
        }

        try {
            const result = await this._request('PUT',
                `/repos/${this.owner}/${this.repo}/contents/data/${path}`,
                body
            );
            this._shaCache[path] = result.content.sha;
            return { success: true };
        } catch (e) {
            // If SHA mismatch, re-fetch and retry once
            if (e.message.includes('409') || e.message.includes('422')) {
                try {
                    await this.readFile(path); // refresh SHA
                    body.sha = this._shaCache[path];
                    const result = await this._request('PUT',
                        `/repos/${this.owner}/${this.repo}/contents/data/${path}`,
                        body
                    );
                    this._shaCache[path] = result.content.sha;
                    return { success: true };
                } catch (retryErr) {
                    return { success: false, error: retryErr.message };
                }
            }
            return { success: false, error: e.message };
        }
    }

    // ===== INITIALIZE REPO WITH SEED DATA =====
    async initializeRepo(seedData) {
        const results = [];
        for (const [filename, data] of Object.entries(seedData)) {
            const existing = await this.readFile(filename);
            if (!existing) {
                const result = await this.writeFile(filename, data, `إنشاء ${filename} - بيانات أولية`);
                results.push({ file: filename, ...result, action: 'created' });
            } else {
                results.push({ file: filename, success: true, action: 'exists' });
            }
        }
        return results;
    }
}

/**
 * SafeCore HSE - Local Data Manager
 * Manages data locally with GitHub sync capability
 */
class DataManager {
    constructor(githubService) {
        this.gh = githubService;
        this.data = {
            users: null,
            assets: null,
            incidents: null,
            permits: null,
            warnings: null,
            chat: null,
            inspections: null
        };
        this._dirty = new Set(); // tracks which files need syncing
    }

    // ===== LOAD ALL DATA =====
    async loadAll() {
        const files = ['users.json', 'assets.json', 'incidents.json', 'permits.json', 'warnings.json', 'chat.json', 'inspections.json'];
        const results = {};

        for (const file of files) {
            const key = file.replace('.json', '');
            try {
                // Try GitHub first
                if (this.gh.isConfigured()) {
                    const ghData = await this.gh.readFile(file);
                    if (ghData) {
                        this.data[key] = ghData;
                        // Also cache locally
                        localStorage.setItem(`hse_${key}`, JSON.stringify(ghData));
                        results[key] = 'github';
                        continue;
                    }
                }
                // Fall back to localStorage
                const local = localStorage.getItem(`hse_${key}`);
                if (local) {
                    this.data[key] = JSON.parse(local);
                    results[key] = 'local';
                } else {
                    results[key] = 'empty';
                }
            } catch (e) {
                // Fall back to localStorage on error
                const local = localStorage.getItem(`hse_${key}`);
                if (local) {
                    this.data[key] = JSON.parse(local);
                    results[key] = 'local-fallback';
                } else {
                    results[key] = 'error';
                }
            }
        }
        return results;
    }

    // ===== SAVE SPECIFIC FILE =====
    async save(key) {
        const filename = key + '.json';
        // Always save locally
        localStorage.setItem(`hse_${key}`, JSON.stringify(this.data[key]));

        // Sync to GitHub if configured
        if (this.gh.isConfigured()) {
            return await this.gh.writeFile(filename, this.data[key]);
        }
        return { success: true, local: true };
    }

    // ===== SYNC ALL DIRTY FILES =====
    async syncAll() {
        const results = [];
        for (const key of this._dirty) {
            const result = await this.save(key);
            results.push({ key, ...result });
        }
        this._dirty.clear();
        return results;
    }

    // ===== HELPER: Mark dirty =====
    markDirty(key) {
        this._dirty.add(key);
    }

    // ===== CRUD: ASSETS =====
    getAssets() { return this.data.assets?.assets || []; }

    getAssetById(id) {
        return this.getAssets().find(a => a.id === id);
    }

    async addAsset(asset) {
        if (!this.data.assets) this.data.assets = { assets: [] };
        asset.id = 'AST-' + Date.now();
        asset.created_at = new Date().toISOString();
        asset.updated_at = asset.created_at;
        this.data.assets.assets.push(asset);
        return await this.save('assets');
    }

    async updateAsset(id, updates) {
        const asset = this.getAssetById(id);
        if (asset) {
            Object.assign(asset, updates, { updated_at: new Date().toISOString() });
            return await this.save('assets');
        }
        return { success: false, error: 'Asset not found' };
    }

    async deleteAsset(id) {
        if (!this.data.assets) return;
        this.data.assets.assets = this.data.assets.assets.filter(a => a.id !== id);
        return await this.save('assets');
    }

    // ===== CRUD: INCIDENTS =====
    getIncidents() { return this.data.incidents?.incidents || []; }

    async addIncident(incident) {
        if (!this.data.incidents) this.data.incidents = { incidents: [] };
        incident.id = 'SC-' + new Date().getFullYear() + '-' + String(this.getIncidents().length + 1).padStart(4, '0');
        incident.created_at = new Date().toISOString();
        incident.updated_at = incident.created_at;
        incident.closed_at = null;
        this.data.incidents.incidents.unshift(incident);
        return await this.save('incidents');
    }

    // ===== CRUD: PERMITS =====
    getPermits() { return this.data.permits?.permits || []; }

    async addPermit(permit) {
        if (!this.data.permits) this.data.permits = { permits: [] };
        permit.id = 'PTW-' + new Date().getFullYear() + '-' + String(this.getPermits().length + 1).padStart(3, '0');
        permit.created_at = new Date().toISOString();
        this.data.permits.permits.unshift(permit);
        return await this.save('permits');
    }

    // ===== CRUD: WARNINGS =====
    getWarnings() { return this.data.warnings?.warnings || []; }

    async addWarning(warning) {
        if (!this.data.warnings) this.data.warnings = { warnings: [] };
        warning.id = 'WRN-' + String(this.getWarnings().length + 1).padStart(3, '0');
        warning.created_at = new Date().toISOString();
        this.data.warnings.warnings.unshift(warning);
        return await this.save('warnings');
    }

    // ===== CRUD: CHAT =====
    getChatRooms() { return this.data.chat?.rooms || []; }

    getChatMessages(roomId) {
        const room = this.getChatRooms().find(r => r.id === roomId);
        return room ? room.messages : [];
    }

    async sendMessage(roomId, message) {
        const room = this.getChatRooms().find(r => r.id === roomId);
        if (room) {
            message.id = 'MSG-' + Date.now();
            message.timestamp = new Date().toISOString();
            room.messages.push(message);
            return await this.save('chat');
        }
        return { success: false, error: 'Room not found' };
    }

    // ===== CRUD: INSPECTIONS =====
    getInspections() { return this.data.inspections?.inspections || []; }

    async addInspection(inspection) {
        if (!this.data.inspections) this.data.inspections = { inspections: [] };
        inspection.id = 'INS-' + String(this.getInspections().length + 1).padStart(3, '0');
        inspection.created_at = new Date().toISOString();
        this.data.inspections.inspections.unshift(inspection);
        return await this.save('inspections');
    }

    // ===== USERS =====
    getUsers() { return this.data.users?.users || []; }
    getOrganization() { return this.data.users?.organization || {}; }

    getUserById(id) {
        return this.getUsers().find(u => u.id === id);
    }

    // ===== STATS =====
    getStats() {
        return {
            assets: this.getAssets().length,
            assets_ok: this.getAssets().filter(a => a.status === 'سليم').length,
            assets_warning: this.getAssets().filter(a => a.status !== 'سليم').length,
            incidents_total: this.getIncidents().length,
            incidents_open: this.getIncidents().filter(i => i.status !== 'تم الحل').length,
            permits_total: this.getPermits().length,
            permits_open: this.getPermits().filter(p => p.status === 'مفتوح').length,
            warnings_total: this.getWarnings().length,
            warnings_active: this.getWarnings().filter(w => w.status === 'نشط').length,
            inspections_total: this.getInspections().length,
            users_total: this.getUsers().length
        };
    }
}

// Export as globals
window.GitHubService = GitHubService;
window.DataManager = DataManager;
