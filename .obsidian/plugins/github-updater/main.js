var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// src/main.ts
var main_exports = {};
__export(main_exports, {
  default: () => GithubUpdaterPlugin
});
module.exports = __toCommonJS(main_exports);
var import_obsidian7 = require("obsidian");

// src/GithubInstallModal.ts
var import_obsidian2 = require("obsidian");

// src/installer.ts
var import_obsidian = require("obsidian");

// src/github.ts
function errorMessage(e) {
  return e instanceof Error ? e.message : String(e);
}

// src/installer.ts
var SAFE_PLUGIN_ID = /^[a-zA-Z0-9_-]+$/;
function repoKeyOf(repo) {
  let r = repo.trim();
  if (r.includes("github.com/")) {
    r = r.split("github.com/")[1];
  }
  if (r.endsWith("/")) {
    r = r.slice(0, -1);
  }
  return r.toLowerCase();
}
function isRepoTracked(trackedRepos, repo) {
  const key = repoKeyOf(repo);
  return trackedRepos.some((tracked) => repoKeyOf(tracked) === key);
}
async function installPluginFromRepo(app, repo, plugin) {
  var _a, _b, _c;
  try {
    let cleanRepo = repo.trim();
    if (cleanRepo.includes("github.com/")) {
      cleanRepo = cleanRepo.split("github.com/")[1];
    }
    if (cleanRepo.endsWith("/")) {
      cleanRepo = cleanRepo.slice(0, -1);
    }
    const token = plugin == null ? void 0 : plugin.settings.githubToken;
    const apiHeaders = token ? { Authorization: `Bearer ${token}` } : void 0;
    new import_obsidian.Notice(`Fetching latest release for ${cleanRepo}...`);
    const releaseUrl = `https://api.github.com/repos/${cleanRepo}/releases/latest`;
    const releaseResponse = await (0, import_obsidian.requestUrl)({ url: releaseUrl, headers: apiHeaders });
    const releaseData = releaseResponse.json;
    const manifestAsset = (_a = releaseData.assets) == null ? void 0 : _a.find((a) => a.name === "manifest.json");
    const mainJsAsset = (_b = releaseData.assets) == null ? void 0 : _b.find((a) => a.name === "main.js");
    const stylesCssAsset = (_c = releaseData.assets) == null ? void 0 : _c.find((a) => a.name === "styles.css");
    const tagName = releaseData.tag_name;
    const rawBaseUrl = `https://raw.githubusercontent.com/${cleanRepo}/${tagName}`;
    let manifestJson;
    try {
      if (manifestAsset) {
        const res = await (0, import_obsidian.requestUrl)({ url: manifestAsset.browser_download_url });
        manifestJson = res.json;
      } else {
        const res = await (0, import_obsidian.requestUrl)({ url: `${rawBaseUrl}/manifest.json` });
        manifestJson = res.json;
      }
    } catch (e) {
      new import_obsidian.Notice(`Failed to download manifest.json for ${cleanRepo}. Ensure the repository has it in the release or root directory.`);
      return null;
    }
    const pluginId = manifestJson.id;
    if (!pluginId || typeof pluginId !== "string" || !SAFE_PLUGIN_ID.test(pluginId)) {
      new import_obsidian.Notice(`Refusing to install from ${cleanRepo}: manifest.json has a missing or unsafe plugin ID.`);
      return null;
    }
    const repoKey = repoKeyOf(repo);
    if (plugin && plugin.settings.repoPluginIds) {
      for (const [knownRepo, knownId] of Object.entries(plugin.settings.repoPluginIds)) {
        if (knownId === pluginId && knownRepo !== repoKey) {
          new import_obsidian.Notice(`Refusing to install from ${cleanRepo}: plugin ID "${pluginId}" was previously installed from ${knownRepo}. Remove that repository from tracking first if this change is intentional.`);
          return null;
        }
      }
    }
    let mainJsArrayBuffer;
    try {
      if (mainJsAsset) {
        const res = await (0, import_obsidian.requestUrl)({ url: mainJsAsset.browser_download_url });
        mainJsArrayBuffer = res.arrayBuffer;
      } else {
        const res = await (0, import_obsidian.requestUrl)({ url: `${rawBaseUrl}/main.js` });
        mainJsArrayBuffer = res.arrayBuffer;
      }
    } catch (e) {
      new import_obsidian.Notice(`Failed to download main.js for ${cleanRepo}. Nothing was written to disk.`);
      return null;
    }
    let stylesArrayBuffer = null;
    try {
      if (stylesCssAsset) {
        const res = await (0, import_obsidian.requestUrl)({ url: stylesCssAsset.browser_download_url });
        stylesArrayBuffer = res.arrayBuffer;
      } else {
        const res = await (0, import_obsidian.requestUrl)({ url: `${rawBaseUrl}/styles.css`, throw: false });
        if (res.status === 200) {
          stylesArrayBuffer = res.arrayBuffer;
        }
      }
    } catch (e) {
    }
    const pluginDir = (0, import_obsidian.normalizePath)(`${app.vault.configDir}/plugins/${pluginId}`);
    const adapter = app.vault.adapter;
    if (!await adapter.exists(pluginDir)) {
      await adapter.mkdir(pluginDir);
    }
    await adapter.writeBinary(`${pluginDir}/main.js`, mainJsArrayBuffer);
    await adapter.write(`${pluginDir}/manifest.json`, JSON.stringify(manifestJson, null, 2));
    if (stylesArrayBuffer) {
      await adapter.writeBinary(`${pluginDir}/styles.css`, stylesArrayBuffer);
    }
    if (plugin) {
      if (!plugin.settings.repoPluginIds) {
        plugin.settings.repoPluginIds = {};
      }
      plugin.settings.repoPluginIds[repoKey] = pluginId;
      await plugin.saveSettings();
    }
    new import_obsidian.Notice(`Successfully installed ${pluginId}! Please reload the app or enable it in Settings.`);
    return pluginId;
  } catch (error) {
    console.error(error);
    new import_obsidian.Notice(`Failed to install ${repo}: ${errorMessage(error)}`);
    return null;
  }
}

// src/GithubInstallModal.ts
var GithubInstallModal = class extends import_obsidian2.Modal {
  constructor(app, plugin) {
    super(app);
    this.repoUrl = "";
    this.plugin = plugin;
  }
  onOpen() {
    const { contentEl } = this;
    contentEl.empty();
    contentEl.createEl("h2", { text: "Install Plugin from GitHub" });
    new import_obsidian2.Setting(contentEl).setName("GitHub Repository").setDesc('Enter the URL or "username/repository" of the plugin you want to install.').addText((text) => text.setPlaceholder("e.g., TfTHacker/obsidian-brat").onChange((value) => {
      this.repoUrl = value;
    }));
    new import_obsidian2.Setting(contentEl).addButton((btn) => btn.setButtonText("Install / Update").setCta().onClick(async () => {
      if (!this.repoUrl) {
        new import_obsidian2.Notice("Please enter a valid repository.");
        return;
      }
      const pluginId = await installPluginFromRepo(this.app, this.repoUrl, this.plugin);
      if (pluginId && !isRepoTracked(this.plugin.settings.trackedRepos, this.repoUrl)) {
        this.plugin.settings.trackedRepos.push(this.repoUrl);
        await this.plugin.saveSettings();
      }
      this.close();
    }));
  }
  onClose() {
    const { contentEl } = this;
    contentEl.empty();
  }
};

// src/GithubUpdaterSettingTab.ts
var import_obsidian6 = require("obsidian");

// src/ReleaseNotesModal.ts
var import_obsidian3 = require("obsidian");
var ReleaseNotesModal = class extends import_obsidian3.Modal {
  constructor(app, repo, version, markdown) {
    super(app);
    this.repo = repo;
    this.version = version;
    this.markdown = markdown;
    this.component = new import_obsidian3.Component();
  }
  onOpen() {
    this.component.load();
    const { contentEl } = this;
    contentEl.empty();
    contentEl.createEl("h2", { text: `Release Notes: ${this.repo} (${this.version})` });
    const markdownContainer = contentEl.createDiv("markdown-rendered");
    void import_obsidian3.MarkdownRenderer.render(this.app, this.markdown, markdownContainer, "", this.component);
  }
  onClose() {
    this.component.unload();
    const { contentEl } = this;
    contentEl.empty();
  }
};

// src/ScanModal.ts
var import_obsidian4 = require("obsidian");
var ScanModal = class extends import_obsidian4.Modal {
  constructor(app, plugin) {
    super(app);
    this.foundPlugins = [];
    this.selectedRepos = /* @__PURE__ */ new Set();
    this.inputs = {};
    this.plugin = plugin;
  }
  async scan() {
    var _a;
    try {
      const response = await (0, import_obsidian4.requestUrl)({ url: "https://raw.githubusercontent.com/obsidianmd/obsidian-releases/master/community-plugins.json" });
      const communityList = response.json;
      const officialIds = new Set(communityList.map((p) => p.id));
      const pluginsDir = (0, import_obsidian4.normalizePath)(`${this.app.vault.configDir}/plugins`);
      const adapter = this.app.vault.adapter;
      const listed = await adapter.list(pluginsDir);
      for (const folderPath of listed.folders) {
        try {
          const manifestPath = `${folderPath}/manifest.json`;
          if (!await adapter.exists(manifestPath)) {
            continue;
          }
          const manifestStr = await adapter.read(manifestPath);
          const manifest = JSON.parse(manifestStr);
          if (!manifest.id) {
            continue;
          }
          if (manifest.id !== this.plugin.manifest.id && !officialIds.has(manifest.id)) {
            let guessedRepo = "";
            if (manifest.authorUrl && manifest.authorUrl.includes("github.com")) {
              let url = manifest.authorUrl;
              if (url.endsWith("/")) url = url.slice(0, -1);
              const parts = url.split("/");
              const username = parts[parts.length - 1];
              guessedRepo = `${username}/${manifest.id}`;
            }
            const manifestId = manifest.id;
            const isAlreadyTracked = this.plugin.settings.trackedRepos.some(
              (repo) => repo.toLowerCase() === guessedRepo.toLowerCase() || repo.toLowerCase().endsWith(`/${manifestId.toLowerCase()}`)
            );
            if (!isAlreadyTracked) {
              this.foundPlugins.push({
                id: manifest.id,
                name: (_a = manifest.name) != null ? _a : manifest.id,
                guessedRepo
              });
            }
          }
        } catch (e) {
          console.warn(`GitHub Updater: skipping ${folderPath} (unreadable manifest.json)`, e);
        }
      }
      this.renderResults();
    } catch (e) {
      console.error(e);
      new import_obsidian4.Notice("Failed to scan plugins: " + errorMessage(e));
      this.close();
    }
  }
  onOpen() {
    const { contentEl } = this;
    contentEl.empty();
    contentEl.createEl("h2", { text: "Scanning for unofficial plugins..." });
    void this.scan();
  }
  renderResults() {
    const { contentEl } = this;
    contentEl.empty();
    contentEl.createEl("h2", { text: "Unofficial Plugins Found" });
    if (this.foundPlugins.length === 0) {
      contentEl.createEl("p", { text: "No other unofficial plugins found in your vault." });
      return;
    }
    contentEl.createEl("p", { text: "Select the plugins you want to track. Please verify the guessed GitHub repository URLs are correct!" });
    this.foundPlugins.forEach((p) => {
      this.inputs[p.id] = p.guessedRepo;
      new import_obsidian4.Setting(contentEl).setName(p.name).setDesc(`ID: ${p.id}`).addText((text) => {
        text.setValue(p.guessedRepo).setPlaceholder("username/repo").onChange((v) => {
          this.inputs[p.id] = v;
        });
      }).addToggle((toggle) => {
        toggle.setValue(false).onChange((v) => {
          if (v) this.selectedRepos.add(p.id);
          else this.selectedRepos.delete(p.id);
        });
      });
    });
    new import_obsidian4.Setting(contentEl).addButton((btn) => btn.setButtonText("Track Selected").setCta().onClick(async () => {
      let added = 0;
      for (const id of this.selectedRepos) {
        const repo = this.inputs[id].trim();
        if (repo && !isRepoTracked(this.plugin.settings.trackedRepos, repo)) {
          this.plugin.settings.trackedRepos.push(repo);
          added++;
        }
      }
      if (added > 0) {
        await this.plugin.saveSettings();
        new import_obsidian4.Notice(`Added ${added} repositories to tracking list.`);
        new import_obsidian4.Notice("Please re-open the settings tab to see the newly tracked plugins.");
      }
      this.close();
    }));
  }
  onClose() {
    const { contentEl } = this;
    contentEl.empty();
  }
};

// src/checker.ts
var import_obsidian5 = require("obsidian");
async function checkPluginStatus(app, repo, token) {
  var _a, _b, _c;
  try {
    let cleanRepo = repo.trim();
    if (cleanRepo.includes("github.com/")) {
      cleanRepo = cleanRepo.split("github.com/")[1];
    }
    if (cleanRepo.endsWith("/")) cleanRepo = cleanRepo.slice(0, -1);
    const apiHeaders = token ? { Authorization: `Bearer ${token}` } : void 0;
    const releaseUrl = `https://api.github.com/repos/${cleanRepo}/releases/latest`;
    const releaseResponse = await (0, import_obsidian5.requestUrl)({ url: releaseUrl, headers: apiHeaders });
    const releaseData = releaseResponse.json;
    const manifestAsset = (_a = releaseData.assets) == null ? void 0 : _a.find((a) => a.name === "manifest.json");
    let remoteManifest;
    if (manifestAsset) {
      const res = await (0, import_obsidian5.requestUrl)({ url: manifestAsset.browser_download_url });
      remoteManifest = res.json;
    } else {
      const tagName = releaseData.tag_name;
      const rawUrl = `https://raw.githubusercontent.com/${cleanRepo}/${tagName}/manifest.json`;
      const res = await (0, import_obsidian5.requestUrl)({ url: rawUrl });
      remoteManifest = res.json;
    }
    const pluginId = remoteManifest.id;
    if (!pluginId || typeof pluginId !== "string" || !SAFE_PLUGIN_ID.test(pluginId)) {
      return { status: "error", errorMsg: `Remote manifest.json for ${cleanRepo} has a missing or unsafe plugin ID.` };
    }
    const remoteVersion = String((_b = remoteManifest.version) != null ? _b : "");
    const releaseNotes = releaseData.body;
    const localManifestPath = (0, import_obsidian5.normalizePath)(`${app.vault.configDir}/plugins/${pluginId}/manifest.json`);
    let localVersion = null;
    if (await app.vault.adapter.exists(localManifestPath)) {
      const localManifestStr = await app.vault.adapter.read(localManifestPath);
      const localManifest = JSON.parse(localManifestStr);
      localVersion = (_c = localManifest.version) != null ? _c : null;
    }
    if (!localVersion) {
      return { status: "not_installed", remoteVersion, localVersion, releaseNotes };
    }
    if (compareVersions(remoteVersion, localVersion) > 0) {
      return { status: "update_available", remoteVersion, localVersion, releaseNotes };
    } else {
      return { status: "up_to_date", remoteVersion, localVersion, releaseNotes };
    }
  } catch (e) {
    return { status: "error", errorMsg: errorMessage(e) };
  }
}
function compareVersions(v1, v2) {
  const parse = (v) => {
    const cleaned = String(v).trim().replace(/^v/i, "");
    const [main, ...preParts] = cleaned.split("-");
    return {
      nums: main.split(".").map((n) => parseInt(n, 10) || 0),
      pre: preParts.join("-")
    };
  };
  const p1 = parse(v1);
  const p2 = parse(v2);
  const maxLen = Math.max(p1.nums.length, p2.nums.length);
  for (let i = 0; i < maxLen; i++) {
    const num1 = p1.nums[i] || 0;
    const num2 = p2.nums[i] || 0;
    if (num1 > num2) return 1;
    if (num1 < num2) return -1;
  }
  if (!p1.pre && p2.pre) return 1;
  if (p1.pre && !p2.pre) return -1;
  if (p1.pre > p2.pre) return 1;
  if (p1.pre < p2.pre) return -1;
  return 0;
}

// src/GithubUpdaterSettingTab.ts
function timeAgo(ts) {
  const seconds = Math.floor((Date.now() - ts) / 1e3);
  if (seconds < 60) return "just now";
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes} minute${minutes === 1 ? "" : "s"} ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours} hour${hours === 1 ? "" : "s"} ago`;
  const days = Math.floor(hours / 24);
  return `${days} day${days === 1 ? "" : "s"} ago`;
}
var GithubUpdaterSettingTab = class extends import_obsidian6.PluginSettingTab {
  constructor(app, plugin) {
    super(app, plugin);
    this.newRepoInput = "";
    this.updatesAvailable = /* @__PURE__ */ new Set();
    this.updateAllBtnComponent = null;
    this.plugin = plugin;
  }
  display() {
    const { containerEl } = this;
    containerEl.empty();
    this.updatesAvailable.clear();
    new import_obsidian6.Setting(containerEl).setHeading().setName("GitHub Plugin Updater Settings");
    new import_obsidian6.Setting(containerEl).setName("Auto-detect Unofficial Plugins").setDesc("Scan your vault for installed plugins that are not in the official community store, and attempt to find their GitHub repository to track them.").addButton((btn) => btn.setButtonText("Scan Vault").onClick(() => {
      new ScanModal(this.app, this.plugin).open();
    }));
    const lastCheckText = this.plugin.settings.lastCheck === 0 ? "Never" : timeAgo(this.plugin.settings.lastCheck);
    new import_obsidian6.Setting(containerEl).setName("Check All Updates").setDesc(`Manually ping GitHub to check for updates across all tracked plugins. Last checked: ${lastCheckText}`).addButton((btn) => btn.setButtonText("Check Now").onClick(async () => {
      btn.setButtonText("Checking...");
      btn.setDisabled(true);
      let count = 0;
      for (const repo of this.plugin.settings.trackedRepos) {
        const result = await checkPluginStatus(this.app, repo, this.plugin.settings.githubToken);
        this.plugin.updateCache[repo] = result;
        if (result.status === "update_available" && this.plugin.settings.ignoredUpdates[repo] !== result.remoteVersion) {
          count++;
        }
      }
      this.plugin.settings.lastCheck = Date.now();
      await this.plugin.saveSettings();
      new import_obsidian6.Notice(`Check complete. ${count} updates available.`);
      this.display();
    }));
    new import_obsidian6.Setting(containerEl).setName("Update All").setDesc("Install all available tracked updates.").addButton((btn) => {
      this.updateAllBtnComponent = btn;
      btn.setButtonText("Update All (0)").setDisabled(true).setCta().onClick(async () => {
        btn.setButtonText("Updating...");
        btn.setDisabled(true);
        for (const repo of this.updatesAvailable) {
          await installPluginFromRepo(this.app, repo, this.plugin);
        }
        new import_obsidian6.Notice("Finished updating plugins.");
        this.plugin.updateCache = {};
        this.display();
      });
    });
    new import_obsidian6.Setting(containerEl).setName("Add Repository").setDesc("Add a GitHub repository (e.g., username/repo) to track for updates.").addText((text) => text.setPlaceholder("TfTHacker/obsidian-brat").onChange((value) => {
      this.newRepoInput = value;
    })).addButton((btn) => btn.setButtonText("Add").setCta().onClick(async () => {
      const repo = this.newRepoInput.trim();
      if (!repo) return;
      if (isRepoTracked(this.plugin.settings.trackedRepos, repo)) {
        new import_obsidian6.Notice("Repository is already tracked.");
        return;
      }
      this.plugin.settings.trackedRepos.push(repo);
      await this.plugin.saveSettings();
      this.display();
    }));
    new import_obsidian6.Setting(containerEl).setName("GitHub API Token (optional)").setDesc("Personal access token used to authenticate update checks against api.github.com, raising the rate limit from 60 to 5,000 requests/hour. Stored in plain text in this plugin's data.json.").addText((text) => {
      text.inputEl.type = "password";
      text.setPlaceholder("ghp_...").setValue(this.plugin.settings.githubToken || "").onChange(async (value) => {
        this.plugin.settings.githubToken = value.trim();
        await this.plugin.saveSettings();
      });
    });
    new import_obsidian6.Setting(containerEl).setHeading().setName("Tracked Repositories");
    if (this.plugin.settings.trackedRepos.length === 0) {
      containerEl.createEl("p", { text: "No repositories tracked yet." });
      return;
    }
    const sortedRepos = [...this.plugin.settings.trackedRepos].sort((a, b) => a.localeCompare(b));
    for (const repo of sortedRepos) {
      const repoSetting = new import_obsidian6.Setting(containerEl).setName(repo).setDesc("Status unknown. Click Check Status.");
      let actionBtn, notesBtn, ignoreBtn;
      repoSetting.addButton((btn) => {
        btn.setIcon("refresh-cw").setTooltip("Check Status").onClick(async () => {
          repoSetting.setDesc("Checking GitHub...");
          const result = await checkPluginStatus(this.app, repo, this.plugin.settings.githubToken);
          this.plugin.updateCache[repo] = result;
          this.plugin.settings.lastCheck = Date.now();
          await this.plugin.saveSettings();
          this.applyResultToUI(repo, repoSetting, actionBtn, notesBtn, ignoreBtn, result);
        });
      });
      repoSetting.addButton((btn) => {
        notesBtn = btn;
        btn.setIcon("file-text").setTooltip("Release Notes").onClick(() => {
          const cached = this.plugin.updateCache[repo];
          if (cached && cached.releaseNotes) {
            new ReleaseNotesModal(this.app, repo, cached.remoteVersion || "", cached.releaseNotes).open();
          } else {
            new import_obsidian6.Notice("Release notes not available.");
          }
        });
        btn.buttonEl.hide();
      });
      repoSetting.addButton((btn) => {
        actionBtn = btn;
        btn.setButtonText("Install/Update").setCta().onClick(async () => {
          btn.setButtonText("Installing...");
          await installPluginFromRepo(this.app, repo, this.plugin);
          this.updatesAvailable.delete(repo);
          this.refreshUpdateAllButton();
          const result = await checkPluginStatus(this.app, repo, this.plugin.settings.githubToken);
          this.plugin.updateCache[repo] = result;
          this.applyResultToUI(repo, repoSetting, actionBtn, notesBtn, ignoreBtn, result);
        });
        btn.buttonEl.hide();
      });
      repoSetting.addButton((btn) => {
        ignoreBtn = btn;
        btn.setButtonText("Ignore Update").onClick(async () => {
          const current = this.plugin.updateCache[repo];
          const remoteVer = current && current.status === "update_available" ? current.remoteVersion : null;
          if (remoteVer) {
            this.plugin.settings.ignoredUpdates[repo] = remoteVer;
            await this.plugin.saveSettings();
            new import_obsidian6.Notice(`Ignored version ${remoteVer} for ${repo}`);
            this.updatesAvailable.delete(repo);
            this.refreshUpdateAllButton();
            const cached = this.plugin.updateCache[repo];
            if (cached) {
              this.applyResultToUI(repo, repoSetting, actionBtn, notesBtn, ignoreBtn, cached);
            }
          }
        });
        btn.buttonEl.hide();
      });
      repoSetting.addButton((btn) => {
        btn.setButtonText("Remove").setWarning().onClick(async () => {
          this.plugin.settings.trackedRepos = this.plugin.settings.trackedRepos.filter((r) => r !== repo);
          delete this.plugin.settings.ignoredUpdates[repo];
          if (this.plugin.settings.repoPluginIds) {
            delete this.plugin.settings.repoPluginIds[repoKeyOf(repo)];
          }
          await this.plugin.saveSettings();
          delete this.plugin.updateCache[repo];
          this.updatesAvailable.delete(repo);
          this.refreshUpdateAllButton();
          this.display();
        });
      });
      const cachedResult = this.plugin.updateCache[repo];
      if (cachedResult) {
        this.applyResultToUI(repo, repoSetting, actionBtn, notesBtn, ignoreBtn, cachedResult);
      }
    }
  }
  refreshUpdateAllButton() {
    if (!this.updateAllBtnComponent) return;
    const count = this.updatesAvailable.size;
    this.updateAllBtnComponent.setButtonText(`Update All (${count})`);
    this.updateAllBtnComponent.setDisabled(count === 0);
  }
  applyResultToUI(repo, setting, actionBtn, notesBtn, ignoreBtn, result) {
    actionBtn.buttonEl.hide();
    notesBtn.buttonEl.hide();
    ignoreBtn.buttonEl.hide();
    if (result.status === "error") {
      setting.setDesc(`Error: ${result.errorMsg}`);
      return;
    }
    if (result.releaseNotes) {
      notesBtn.buttonEl.show();
    }
    if (result.status === "not_installed") {
      setting.setDesc(`Not installed. Remote version: ${result.remoteVersion}`);
      actionBtn.setButtonText("Install");
      actionBtn.buttonEl.show();
      return;
    }
    if (result.status === "up_to_date") {
      setting.setDesc(`Up to date. Version: ${result.localVersion}`);
      return;
    }
    if (result.status === "update_available") {
      const ignoredVer = this.plugin.settings.ignoredUpdates[repo];
      if (ignoredVer === result.remoteVersion) {
        setting.setDesc(`Update available (${result.remoteVersion}), but ignored. Local: ${result.localVersion}`);
        actionBtn.setButtonText("Update (Ignored)");
        actionBtn.removeCta();
        actionBtn.buttonEl.show();
      } else {
        setting.setDesc(`Update available! Local: ${result.localVersion} -> Remote: ${result.remoteVersion}`);
        actionBtn.setButtonText("Update");
        actionBtn.setCta();
        actionBtn.buttonEl.show();
        ignoreBtn.buttonEl.show();
        this.updatesAvailable.add(repo);
        this.refreshUpdateAllButton();
      }
    }
  }
};

// src/main.ts
var DEFAULT_SETTINGS = {
  trackedRepos: [],
  ignoredUpdates: {},
  lastCheck: 0,
  githubToken: "",
  repoPluginIds: {}
};
var STARTUP_CHECK_MIN_INTERVAL = 36e5;
var GithubUpdaterPlugin = class extends import_obsidian7.Plugin {
  constructor() {
    super(...arguments);
    this.updateCache = {};
    this.isUnloaded = false;
  }
  async onload() {
    await this.loadSettings();
    this.addSettingTab(new GithubUpdaterSettingTab(this.app, this));
    this.addRibbonIcon("github", "Install Plugin from GitHub", () => {
      new GithubInstallModal(this.app, this).open();
    });
    this.addCommand({
      id: "open-github-installer-modal",
      name: "Install plugin from GitHub",
      callback: () => {
        new GithubInstallModal(this.app, this).open();
      }
    });
    this.app.workspace.onLayoutReady(() => {
      this.registerInterval(window.setTimeout(() => {
        this.runBackgroundUpdateCheck().catch(console.error);
      }, 5e3));
    });
  }
  onunload() {
    this.isUnloaded = true;
  }
  async runBackgroundUpdateCheck() {
    if (Date.now() - this.settings.lastCheck < STARTUP_CHECK_MIN_INTERVAL) {
      return;
    }
    let updatesFound = 0;
    for (const repo of this.settings.trackedRepos) {
      if (this.isUnloaded) {
        return;
      }
      const result = await checkPluginStatus(this.app, repo, this.settings.githubToken);
      this.updateCache[repo] = result;
      if (result.status === "update_available") {
        const ignoredVer = this.settings.ignoredUpdates[repo];
        if (ignoredVer !== result.remoteVersion) {
          updatesFound++;
        }
      }
    }
    if (this.isUnloaded) {
      return;
    }
    if (updatesFound > 0) {
      new import_obsidian7.Notice(`GitHub Plugin Updater: ${updatesFound} update(s) available! Check settings to install.`);
    }
    this.settings.lastCheck = Date.now();
    await this.saveSettings();
  }
  async loadSettings() {
    const data = await this.loadData();
    this.settings = Object.assign({}, DEFAULT_SETTINGS, data);
  }
  async saveSettings() {
    await this.saveData(this.settings);
  }
};

/* nosourcemap */