var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
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
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// main.ts
var main_exports = {};
__export(main_exports, {
  default: () => GitHubPublishPlugin
});
module.exports = __toCommonJS(main_exports);
var import_obsidian15 = require("obsidian");

// src/utils/request.ts
var import_obsidian = require("obsidian");
async function fetchUrl(params) {
  const response = await (0, import_obsidian.requestUrl)(params);
  return response;
}

// src/log.ts
var PREFIX = "[GitHub Publish]";
function log(message, ...details) {
  if (details.length > 0) {
    console.log(PREFIX, message, ...details);
  } else {
    console.log(PREFIX, message);
  }
}
function logWarn(message, ...details) {
  if (details.length > 0) {
    console.warn(PREFIX, message, ...details);
  } else {
    console.warn(PREFIX, message);
  }
}
function logError(message, ...details) {
  if (details.length > 0) {
    console.error(PREFIX, message, ...details);
  } else {
    console.error(PREFIX, message);
  }
}

// src/utils/json.ts
function parseJson(text) {
  const parsed = JSON.parse(text);
  return parsed;
}

// src/github/client.ts
var GITHUB_API = "https://api.github.com";
var GitHubApiError = class extends Error {
  constructor(message, status, body) {
    super(message);
    this.status = status;
    this.body = body;
    this.name = "GitHubApiError";
  }
};
function formatGitHubError(method, apiPath, status, body) {
  const detail = parseGitHubErrorMessage(body);
  return detail ? `GitHub API ${method} ${apiPath} failed (${status}): ${detail}` : `GitHub API ${method} ${apiPath} failed (${status})`;
}
function isGitRepositoryEmptyError(error) {
  if (error.status !== 409) return false;
  if (!error.body) return false;
  try {
    const parsed = parseJson(error.body);
    return parsed.message === "Git Repository is empty.";
  } catch {
    return error.body.includes("Git Repository is empty");
  }
}
function isMissingBranchRefError(error) {
  if (!(error instanceof GitHubApiError)) return false;
  return error.status === 404 || isGitRepositoryEmptyError(error);
}
function parseGitHubErrorMessage(body) {
  if (!body) return void 0;
  try {
    const parsed = parseJson(body);
    return parsed.message;
  } catch {
    return body.length > 200 ? `${body.slice(0, 200)}\u2026` : body;
  }
}
function sleep(ms) {
  return new Promise((resolve) => window.setTimeout(resolve, ms));
}
async function githubRequest(token, method, apiPath, body) {
  const headers = {
    Accept: "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
    "User-Agent": "GitHub-Publish-Obsidian-Plugin"
  };
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }
  log(`${method} ${apiPath}`);
  const response = await fetchUrl({
    url: apiPath.startsWith("http") ? apiPath : `${GITHUB_API}${apiPath}`,
    method,
    headers,
    body: body !== void 0 ? JSON.stringify(body) : void 0,
    contentType: "application/json",
    throw: false
  });
  if (response.status >= 400) {
    logWarn(`${method} ${apiPath} \u2192 ${response.status}`, response.text);
    throw new GitHubApiError(
      formatGitHubError(method, apiPath, response.status, response.text),
      response.status,
      response.text
    );
  }
  log(`${method} ${apiPath} \u2192 ${response.status}`);
  if (!response.text || response.text.length === 0) {
    return {};
  }
  return parseJson(response.text);
}
async function githubRequestWithRetry(token, method, apiPath, body, options) {
  const maxAttempts = options?.maxAttempts ?? 8;
  const retryStatuses = options?.retryStatuses ?? [409];
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await githubRequest(token, method, apiPath, body);
    } catch (error) {
      const shouldRetry = error instanceof GitHubApiError && retryStatuses.includes(error.status) && attempt < maxAttempts - 1;
      if (!shouldRetry) throw error;
      const delayMs = Math.min(1e3 * 2 ** attempt, 16e3);
      logWarn(`Retry ${attempt + 2}/${maxAttempts} in ${delayMs}ms after ${error.status}: ${method} ${apiPath}`);
      await sleep(delayMs);
    }
  }
  throw new Error("GitHub request retry loop exhausted");
}
async function githubFormRequest(url, fields) {
  const body = new URLSearchParams(fields).toString();
  const response = await fetchUrl({
    url,
    method: "POST",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/x-www-form-urlencoded"
    },
    body,
    throw: false
  });
  if (response.status >= 400) {
    throw new GitHubApiError(
      `GitHub request failed (${response.status})`,
      response.status,
      response.text
    );
  }
  return parseJson(response.text);
}

// src/github/auth.ts
var DEVICE_CODE_URL = "https://github.com/login/device/code";
var ACCESS_TOKEN_URL = "https://github.com/login/oauth/access_token";
var OAUTH_SCOPES = "public_repo workflow";
async function requestDeviceCode(clientId) {
  return githubFormRequest(DEVICE_CODE_URL, {
    client_id: clientId,
    scope: OAUTH_SCOPES
  });
}
async function pollAccessToken(clientId, deviceCode, intervalSeconds, onPending) {
  const maxAttempts = 120;
  let attempts = 0;
  while (attempts < maxAttempts) {
    await sleep(intervalSeconds * 1e3);
    attempts++;
    const result = await githubFormRequest(ACCESS_TOKEN_URL, {
      client_id: clientId,
      device_code: deviceCode,
      grant_type: "urn:ietf:params:oauth:grant-type:device_code"
    });
    if (result.access_token) {
      return result.access_token;
    }
    if (result.error === "authorization_pending") {
      onPending?.();
      continue;
    }
    if (result.error === "slow_down") {
      intervalSeconds += 5;
      onPending?.();
      continue;
    }
    throw new Error(result.error_description ?? result.error ?? "Device flow failed");
  }
  throw new Error("GitHub authorization timed out. Please try again.");
}
async function fetchGitHubUser(token) {
  return githubRequest(token, "GET", "/user");
}

// src/github/connect.ts
var import_obsidian2 = require("obsidian");

// src/github/oauthConfig.ts
var GITHUB_OAUTH_CLIENT_ID = "Ov23litVODtLGZBUBmgr";

// src/github/connect.ts
async function connectGitHub(plugin, callbacks) {
  const device = await requestDeviceCode(GITHUB_OAUTH_CLIENT_ID);
  callbacks?.onUserCode?.(device.user_code, device.verification_uri);
  window.open(device.verification_uri, "_blank");
  const token = await pollAccessToken(
    GITHUB_OAUTH_CLIENT_ID,
    device.device_code,
    device.interval,
    () => {
      callbacks?.onPending?.();
      new import_obsidian2.Notice("Waiting for GitHub authorization\u2026");
    }
  );
  return plugin.setAccessToken(token);
}

// src/settings.ts
var DEFAULT_SETTINGS = {
  accessToken: null,
  githubUsername: null,
  publishedSites: [],
  savedSetup: null,
  quartzCommitSha: null
};

// src/sites.ts
function siteId(owner, repo) {
  return `${owner}/${repo}`;
}
function getSiteLiveUrl(site) {
  return `https://${site.owner}.github.io/${site.repo}/`;
}
function getSiteRepoUrl(site) {
  return `https://github.com/${site.owner}/${site.repo}`;
}
function isPublishedSite(site) {
  return Boolean(site.owner && site.repo && site.lastPublishedCommitSha);
}
function publishedSiteFromPublishResult(config, owner, repo, commitSha, manifest, configHash, toolchainHash) {
  return {
    id: siteId(owner, repo),
    owner,
    repo,
    siteName: config.siteName,
    contentFolder: config.contentFolder,
    lastPublishedCommitSha: commitSha,
    manifest,
    templateEngine: "quartz",
    quartzCommitSha: config.quartzCommitSha ?? null,
    configHash,
    toolchainHash
  };
}
function upsertPublishedSite(sites, site) {
  const index = sites.findIndex((entry) => entry.id === site.id);
  if (index === -1) {
    return [...sites, site];
  }
  const next = [...sites];
  next[index] = site;
  return next;
}
function updatePublishedSite(sites, id, update) {
  return sites.map((site) => site.id === id ? { ...site, ...update } : site);
}
function removePublishedSite(sites, id) {
  return sites.filter((site) => site.id !== id);
}
function migratePluginSettings(raw) {
  const settings = {
    accessToken: raw.accessToken ?? null,
    githubUsername: raw.githubUsername ?? null,
    publishedSites: Array.isArray(raw.publishedSites) ? raw.publishedSites : [],
    savedSetup: raw.savedSetup ?? null,
    quartzCommitSha: raw.quartzCommitSha ?? null
  };
  if (settings.publishedSites.length > 0) {
    return settings;
  }
  if (raw.owner && raw.repo && raw.lastPublishedCommitSha && raw.contentFolder) {
    settings.publishedSites = [
      {
        id: siteId(raw.owner, raw.repo),
        owner: raw.owner,
        repo: raw.repo,
        siteName: raw.siteName ?? raw.repo,
        contentFolder: raw.contentFolder,
        lastPublishedCommitSha: raw.lastPublishedCommitSha,
        manifest: raw.manifest ?? {},
        templateEngine: "quartz",
        quartzCommitSha: raw.quartzCommitSha ?? null
      }
    ];
  }
  return settings;
}

// src/ui/SetupModal.ts
var import_obsidian10 = require("obsidian");

// src/github/repos.ts
async function listUserRepos(token) {
  const repos = [];
  let page = 1;
  while (page <= 5) {
    const batch = await githubRequest(
      token,
      "GET",
      `/user/repos?per_page=100&page=${page}&sort=updated`
    );
    if (!batch.length) break;
    repos.push(...batch);
    if (batch.length < 100) break;
    page++;
  }
  return repos;
}
async function createRepo(token, name, isPrivate = false, autoInit = false) {
  return githubRequest(token, "POST", "/user/repos", {
    name,
    private: isPrivate,
    auto_init: autoInit
  });
}
async function resolveRepository(token, username, repoName, mode) {
  if (mode === "existing") {
    const existing = await getRepo(token, username, repoName);
    return {
      owner: existing.owner.login,
      repoName: existing.name,
      created: false
    };
  }
  try {
    const created = await createRepo(token, repoName, false, false);
    return {
      owner: created.owner.login,
      repoName: created.name,
      created: true
    };
  } catch (error) {
    if (error instanceof GitHubApiError && error.status === 422) {
      log(`Repository ${username}/${repoName} already exists \u2014 continuing publish`);
      const existing = await getRepo(token, username, repoName);
      return {
        owner: existing.owner.login,
        repoName: existing.name,
        created: false
      };
    }
    throw error;
  }
}
async function getRepo(token, owner, repo) {
  return githubRequest(token, "GET", `/repos/${owner}/${repo}`);
}
async function userRepoExists(token, username, repoName) {
  try {
    await getRepo(token, username, repoName);
    return true;
  } catch (error) {
    if (error instanceof GitHubApiError && error.status === 404) {
      return false;
    }
    throw error;
  }
}

// src/publish/scanVault.ts
var import_obsidian4 = require("obsidian");

// src/utils/vault.ts
var import_obsidian3 = require("obsidian");
function asArrayBuffer(value) {
  return value;
}
function getVaultFolder(vault, folderPath) {
  const folder = vault.getAbstractFileByPath(folderPath);
  if (!(folder instanceof import_obsidian3.TFolder)) {
    throw new Error(`Folder not found: ${folderPath}`);
  }
  return folder;
}
function getVaultRootFolder(vault) {
  return vault.getRoot();
}
function asFile(file) {
  return file instanceof import_obsidian3.TFile ? file : null;
}
async function readVaultBinary(vault, file) {
  const arrayBuffer = asArrayBuffer(await vault.readBinary(file));
  return new Uint8Array(arrayBuffer);
}

// src/publish/scanVault.ts
var EXCLUDED_DIR_NAMES = /* @__PURE__ */ new Set([".git", "node_modules"]);
var EXCLUDED_FILES = /* @__PURE__ */ new Set([".DS_Store"]);
var INCLUDED_EXTENSIONS = /* @__PURE__ */ new Set([
  ".md",
  ".canvas",
  ".png",
  ".jpg",
  ".jpeg",
  ".gif",
  ".webp",
  ".pdf",
  ".mp3"
]);
var TEXT_EXTENSIONS = /* @__PURE__ */ new Set(["md", "canvas"]);
function transformCanvasForPublish(content, rootPath) {
  try {
    const text = new TextDecoder("utf-8").decode(content);
    const canvas = JSON.parse(text);
    const folderName = rootPath.split("/").filter(Boolean).pop() || "";
    if (canvas.nodes) {
      canvas.nodes = canvas.nodes.map((node) => {
        if (node.type === "file" && node.file) {
          let filePath = node.file;
          if (folderName && filePath.startsWith(folderName + "/")) {
            filePath = filePath.slice(folderName.length + 1);
          }
          if (!filePath.match(/\.(md|png|jpg|jpeg|gif|webp|pdf|mp3|canvas)$/i)) {
            filePath = filePath + ".md";
          }
          node.file = filePath;
        }
        return node;
      });
    }
    const transformed = JSON.stringify(canvas, null, 2);
    return new TextEncoder().encode(transformed);
  } catch (error) {
    return content;
  }
}
function normalizePath(path) {
  return path.replace(/\\/g, "/").replace(/\/$/, "");
}
function isConfigDir(vault, folder) {
  return normalizePath(folder.path) === normalizePath(vault.configDir);
}
function shouldExcludeDir(vault, folder) {
  if (EXCLUDED_DIR_NAMES.has(folder.name)) {
    return true;
  }
  return isConfigDir(vault, folder);
}
async function scanVaultFolder(vault, folderPath) {
  const folder = getVaultFolder(vault, folderPath);
  const files = [];
  const warnings = [];
  await walkFolder(vault, folder, folderPath, files, warnings);
  return { files, warnings };
}
async function walkFolder(vault, folder, rootPath, files, warnings) {
  for (const child of folder.children) {
    if (child instanceof import_obsidian4.TFolder) {
      if (shouldExcludeDir(vault, child)) continue;
      await walkFolder(vault, child, rootPath, files, warnings);
      continue;
    }
    const file = asFile(child);
    if (!file) continue;
    const relative = file.path.slice(rootPath.length).replace(/^\//, "");
    const skip = shouldSkip(relative);
    if (skip === true) continue;
    if (typeof skip === "string") {
      warnings.push(skip);
      continue;
    }
    const repoPath = `content/${file.path.slice(rootPath.length).replace(/^\//, "")}`;
    let content = await readVaultBinary(vault, file);
    const ext = file.extension.toLowerCase();
    const encoding = TEXT_EXTENSIONS.has(ext) ? "utf-8" : "base64";
    if (ext === "canvas") {
      content = transformCanvasForPublish(content, rootPath);
    }
    files.push({ path: repoPath, content, encoding });
  }
}
function shouldSkip(relativePath) {
  const basename = relativePath.split("/").pop() ?? relativePath;
  if (EXCLUDED_FILES.has(basename)) return true;
  if (relativePath.toLowerCase().endsWith(".excalidraw.md")) {
    return `Skipping Excalidraw note: ${relativePath}`;
  }
  const fileExt = "." + (basename.includes(".") ? basename.split(".").pop()?.toLowerCase() : "");
  if (!INCLUDED_EXTENSIONS.has(fileExt)) return true;
  return false;
}
function countFilesInFolder(vault, folderPath) {
  const folder = folderPath === "" ? getVaultRootFolder(vault) : getVaultFolder(vault, folderPath);
  let count = 0;
  const walk = (node) => {
    if (node instanceof import_obsidian4.TFolder) {
      if (shouldExcludeDir(vault, node)) return;
      node.children.forEach(walk);
      return;
    }
    const file = asFile(node);
    if (!file) return;
    const relative = file.path.slice(folderPath.length).replace(/^\//, "");
    if (shouldSkip(relative) === false) count++;
  };
  walk(folder);
  return count;
}

// src/publish/startPublish.ts
var import_obsidian8 = require("obsidian");

// src/quartz/versions.ts
var DEFAULT_QUARTZ_COMMIT = "9cf87ff1c248a8ca551093214b0fec3b31415009";
var TESTED_QUARTZ_VERSIONS = [
  { sha: DEFAULT_QUARTZ_COMMIT, label: "Quartz v5 (Jun 2026)" }
];
function resolveQuartzCommitSha(settingsSha) {
  const trimmed = settingsSha?.trim();
  return trimmed || DEFAULT_QUARTZ_COMMIT;
}
function getQuartzVersionLabel(sha) {
  const known = TESTED_QUARTZ_VERSIONS.find((version) => version.sha === sha);
  return known?.label ?? `${sha.slice(0, 7)}\u2026`;
}

// src/publish/diffVault.ts
function hashFileContent(bytes) {
  let hash = 0;
  for (const byte of bytes) {
    hash = hash * 31 + byte >>> 0;
  }
  return `hash:${hash.toString(16)}`;
}
function buildContentManifest(files) {
  const manifest = {};
  for (const file of files) {
    if (!file.path.startsWith("content/")) continue;
    manifest[file.path] = hashFileContent(file.content);
  }
  return manifest;
}
function diffAgainstManifest(manifest, scannedFiles) {
  const adds = [];
  const updates = [];
  const unchanged = [];
  const seen = /* @__PURE__ */ new Set();
  for (const file of scannedFiles) {
    if (!file.path.startsWith("content/")) continue;
    seen.add(file.path);
    const hash = hashFileContent(file.content);
    const previous = manifest[file.path];
    if (previous === void 0) {
      adds.push(file);
    } else if (previous !== hash) {
      updates.push(file);
    } else {
      unchanged.push(file.path);
    }
  }
  const deletes = [];
  for (const path of Object.keys(manifest)) {
    if (!seen.has(path)) {
      deletes.push(path);
    }
  }
  return { adds, updates, deletes, unchanged };
}
function countDiffChanges(diff) {
  return diff.adds.length + diff.updates.length + diff.deletes.length;
}
function formatDiffSummary(diff) {
  const total = countDiffChanges(diff);
  if (total === 0) return "Up to date";
  const parts = [];
  if (diff.adds.length) parts.push(`${diff.adds.length} added`);
  if (diff.updates.length) parts.push(`${diff.updates.length} updated`);
  if (diff.deletes.length) parts.push(`${diff.deletes.length} deleted`);
  return `${total} change${total === 1 ? "" : "s"} (${parts.join(", ")})`;
}
function mergeManifestAfterPublish(manifest, diff) {
  const next = { ...manifest };
  for (const path of diff.deletes) {
    delete next[path];
  }
  for (const file of [...diff.adds, ...diff.updates]) {
    next[file.path] = hashFileContent(file.content);
  }
  return next;
}

// src/github/actions.ts
function repoActionsUrl(owner, repo) {
  return `https://github.com/${owner}/${repo}/actions`;
}
async function findWorkflowRunForCommit(token, owner, repo, commitSha) {
  const response = await githubRequest(
    token,
    "GET",
    `/repos/${owner}/${repo}/actions/runs?branch=main&event=push&per_page=10`
  );
  return response.workflow_runs.find((run) => run.head_sha === commitSha) ?? null;
}
var ACTIONS_POLL_INTERVAL_MS = 8e3;
var ACTIONS_TIMEOUT_MS = 15 * 60 * 1e3;
async function pollWorkflowRun(token, owner, repo, commitSha, onUpdate, intervalMs = ACTIONS_POLL_INTERVAL_MS, maxAttempts = Math.ceil(ACTIONS_TIMEOUT_MS / ACTIONS_POLL_INTERVAL_MS)) {
  let attempts = 0;
  while (attempts < maxAttempts) {
    const run = await findWorkflowRunForCommit(token, owner, repo, commitSha);
    onUpdate(run);
    if (run && run.status === "completed") {
      if (run.conclusion !== "success") {
        throw new Error(`GitHub Actions failed: ${run.html_url}`);
      }
      return run;
    }
    await sleep(intervalMs);
    attempts++;
  }
  throw new Error("Timed out waiting for GitHub Actions to complete (15 minute limit).");
}

// src/github/pages.ts
async function enableGitHubPages(token, owner, repo) {
  const body = { build_type: "workflow" };
  if (await pagesUsesWorkflowBuild(token, owner, repo)) {
    log(`GitHub Pages already uses workflow build for ${owner}/${repo}`);
    return;
  }
  try {
    await githubRequest(token, "POST", `/repos/${owner}/${repo}/pages`, body);
    log(`Enabled GitHub Pages (workflow) for ${owner}/${repo}`);
    return;
  } catch (error) {
    if (!(error instanceof GitHubApiError)) throw error;
    if (error.status === 409 || error.status === 422) {
      await githubRequest(token, "PUT", `/repos/${owner}/${repo}/pages`, body);
      log(`Updated GitHub Pages (workflow) for ${owner}/${repo}`);
      return;
    }
    throw error;
  }
}
async function pagesUsesWorkflowBuild(token, owner, repo) {
  try {
    const site = await githubRequest(
      token,
      "GET",
      `/repos/${owner}/${repo}/pages`
    );
    return site.build_type === "workflow";
  } catch (error) {
    if (error instanceof GitHubApiError && error.status === 404) {
      return false;
    }
    throw error;
  }
}

// src/github/graphql.ts
async function runGraphQLMutation(token, label, query, variables) {
  const result = await githubRequest(
    token,
    "POST",
    "https://api.github.com/graphql",
    { query, variables }
  );
  if (result.errors?.length) {
    logError(`GraphQL ${label} errors`, result.errors);
    const message = result.errors[0].message;
    const hint = label === "updateRef" && message.includes("correct permissions") ? " Reconnect GitHub in settings \u2014 publish requires the workflow scope when commits include .github/workflows/." : "";
    throw new GitHubApiError(
      `GitHub GraphQL ${label} failed: ${message}.${hint}`,
      422,
      JSON.stringify(result.errors)
    );
  }
  log(`GraphQL ${label} response`, result);
  return result.data;
}
async function updateBranchRefGraphQL(token, refId, commitOid, force = false) {
  if (!refId) {
    throw new Error("Ref node_id is missing \u2014 cannot update branch via GraphQL.");
  }
  log(`Updating ref ${refId.slice(0, 12)}\u2026 via GraphQL to ${commitOid.slice(0, 7)}`);
  const data = await runGraphQLMutation(
    token,
    "updateRef",
    `mutation($input: UpdateRefInput!) {
      updateRef(input: $input) {
        ref {
          name
          target { oid }
        }
      }
    }`,
    {
      input: {
        refId,
        oid: commitOid,
        force
      }
    }
  );
  const ref = data.updateRef?.ref;
  const oid = ref?.target?.oid;
  if (!ref?.name || !oid) {
    throw new GitHubApiError(
      "GitHub GraphQL updateRef returned no ref \u2014 branch was not updated.",
      422,
      JSON.stringify(data)
    );
  }
  if (oid !== commitOid) {
    throw new GitHubApiError(
      `GitHub GraphQL updateRef target mismatch (expected ${commitOid.slice(0, 7)}, got ${oid.slice(0, 7)}).`,
      422,
      JSON.stringify(data)
    );
  }
  log(`GraphQL updated ${ref.name} to ${oid.slice(0, 7)}`);
}
async function createBranchRefGraphQL(token, repositoryNodeId, branch, commitOid) {
  if (!repositoryNodeId) {
    throw new Error("Repository node_id is missing \u2014 cannot create branch via GraphQL.");
  }
  log(`Creating refs/heads/${branch} via GraphQL at ${commitOid.slice(0, 7)}`);
  const data = await runGraphQLMutation(
    token,
    "createRef",
    `mutation($input: CreateRefInput!) {
      createRef(input: $input) {
        ref {
          name
          target { oid }
        }
      }
    }`,
    {
      input: {
        name: `refs/heads/${branch}`,
        oid: commitOid,
        repositoryId: repositoryNodeId
      }
    }
  );
  const ref = data.createRef?.ref;
  const oid = ref?.target?.oid;
  if (!ref?.name || !oid) {
    throw new GitHubApiError(
      "GitHub GraphQL createRef returned no ref \u2014 branch was not created.",
      422,
      JSON.stringify(data)
    );
  }
  if (oid !== commitOid) {
    throw new GitHubApiError(
      `GitHub GraphQL createRef target mismatch (expected ${commitOid.slice(0, 7)}, got ${oid.slice(0, 7)}).`,
      422,
      JSON.stringify(data)
    );
  }
  log(`GraphQL created ${ref.name} at ${oid.slice(0, 7)}`);
}

// src/github/contents.ts
var MAX_FILE_BYTES = 100 * 1024 * 1024;
async function putFileContents(token, owner, repo, path, content, message) {
  const existingSha = await getFileContentsSha(token, owner, repo, path);
  log(
    `PUT contents/${path}${existingSha ? ` (update, sha ${existingSha.slice(0, 7)})` : " (create)"}`
  );
  const response = await githubRequest(
    token,
    "PUT",
    `/repos/${owner}/${repo}/contents/${encodeRepoPath(path)}`,
    {
      message,
      content: bytesToBase64(content),
      ...existingSha ? { sha: existingSha } : {}
    }
  );
  return response.commit.sha;
}
async function getFileContentsSha(token, owner, repo, path) {
  try {
    const response = await githubRequest(
      token,
      "GET",
      `/repos/${owner}/${repo}/contents/${encodeRepoPath(path)}`
    );
    return response.sha;
  } catch (error) {
    if (error instanceof GitHubApiError && error.status === 404) {
      return void 0;
    }
    throw error;
  }
}
function encodeRepoPath(path) {
  return path.split("/").map((segment) => encodeURIComponent(segment)).join("/");
}
function bytesToBase64(bytes) {
  let binary = "";
  const chunk = 32768;
  for (let i = 0; i < bytes.length; i += chunk) {
    binary += String.fromCharCode(...bytes.subarray(i, i + chunk));
  }
  return btoa(binary);
}

// src/github/git.ts
var MAX_FILE_BYTES2 = 100 * 1024 * 1024;
var GIT_RETRY_STATUSES = [409];
async function ensureRepositoryReadyForGit(token, owner, repo, onStatus) {
  const repoInfo = await getRepo(token, owner, repo);
  const branch = repoInfo.default_branch || "main";
  if (await branchExists(token, owner, repo, branch)) {
    log(`Repository ${owner}/${repo} already has branch ${branch}`);
    return;
  }
  const blobPath = `/repos/${owner}/${repo}/git/blobs`;
  log(`Preparing ${owner}/${repo} for Git upload`);
  for (let attempt = 0; attempt < 8; attempt++) {
    onStatus?.(`Checking Git API (attempt ${attempt + 1}/8)\u2026`);
    try {
      await githubRequest(token, "POST", blobPath, {
        content: "github-publish-ready-probe",
        encoding: "utf-8"
      });
      log(`Repository ${owner}/${repo} is ready for Git upload`);
      return;
    } catch (error) {
      if (!(error instanceof GitHubApiError) || error.status !== 409) {
        throw error;
      }
      if (isGitRepositoryEmptyError(error)) {
        onStatus?.("Initializing repository\u2026");
        log(`Repository ${owner}/${repo} is empty \u2014 initializing via Contents API`);
        await initializeRepository(token, owner, repo);
        log(`Repository ${owner}/${repo} initialized`);
        return;
      }
      logWarn(`Git API not ready for ${owner}/${repo} (409), attempt ${attempt + 1}/8`);
      if (attempt < 7) {
        const delayMs = Math.min(1e3 * 2 ** attempt, 16e3);
        onStatus?.(`Waiting for repository (${attempt + 1}/8, retry in ${Math.round(delayMs / 1e3)}s)\u2026`);
        await sleep(delayMs);
        continue;
      }
      onStatus?.("Initializing repository\u2026");
      log(`Initializing ${owner}/${repo} via Contents API after repeated 409 responses`);
      await initializeRepository(token, owner, repo);
      log(`Repository ${owner}/${repo} initialized`);
      return;
    }
  }
}
async function initializeRepository(token, owner, repo) {
  try {
    await putFileContents(
      token,
      owner,
      repo,
      ".github-publish-init",
      new Uint8Array(),
      "Initialize repository for GitHub Publish"
    );
  } catch (error) {
    if (error instanceof GitHubApiError && error.status === 422) {
      const repoInfo = await getRepo(token, owner, repo);
      const branch = repoInfo.default_branch || "main";
      if (await branchExists(token, owner, repo, branch)) {
        log(`Repository ${owner}/${repo} already initialized`);
        return;
      }
    }
    throw error;
  }
}
async function createInitialCommit(token, owner, repo, files, message, onProgress) {
  for (const file of files) {
    if (file.content.byteLength > MAX_FILE_BYTES2) {
      throw new Error(`File too large for GitHub (>100MB): ${file.path}`);
    }
  }
  const treeItems = [];
  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    onProgress?.(i + 1, files.length);
    const blob = await githubRequestWithRetry(
      token,
      "POST",
      `/repos/${owner}/${repo}/git/blobs`,
      {
        content: file.encoding === "utf-8" ? new TextDecoder().decode(file.content) : uint8ArrayToBase64(file.content),
        encoding: file.encoding
      },
      { retryStatuses: GIT_RETRY_STATUSES }
    );
    if (!blob.sha) {
      throw new Error(`GitHub returned an empty blob SHA for ${file.path}`);
    }
    treeItems.push({
      path: normalizeRepoPath(file.path),
      sha: blob.sha
    });
  }
  log(`Creating Git tree for ${treeItems.length} files in ${owner}/${repo}`);
  const treeSha = await createHierarchicalTree(token, owner, repo, treeItems);
  return createCommitAndUpdateBranch(token, owner, repo, treeSha, message);
}
async function createContentUpdateCommit(token, owner, repo, files, deletes, message, onProgress) {
  if (files.length === 0 && deletes.length === 0) {
    throw new Error("No content changes to publish.");
  }
  for (const file of files) {
    if (file.content.byteLength > MAX_FILE_BYTES2) {
      throw new Error(`File too large for GitHub (>100MB): ${file.path}`);
    }
  }
  const totalSteps = files.length + 1;
  let step = 0;
  const attemptCommit = async () => {
    const repoInfo = await getRepo(token, owner, repo);
    const branch = repoInfo.default_branch || "main";
    const branchRef = await getBranchRef(token, owner, repo, branch);
    if (!branchRef) {
      throw new Error(`Branch ${branch} does not exist \u2014 run initial publish first.`);
    }
    const parentSha = branchRef.object.sha;
    const parentCommit = await githubRequest(
      token,
      "GET",
      `/repos/${owner}/${repo}/git/commits/${parentSha}`
    );
    const baseTreeSha = parentCommit.tree.sha;
    const tree = [];
    for (const file of files) {
      step++;
      onProgress?.(step, totalSteps);
      const blob = await githubRequestWithRetry(
        token,
        "POST",
        `/repos/${owner}/${repo}/git/blobs`,
        {
          content: file.encoding === "utf-8" ? new TextDecoder().decode(file.content) : uint8ArrayToBase64(file.content),
          encoding: file.encoding
        },
        { retryStatuses: GIT_RETRY_STATUSES }
      );
      if (!blob.sha) {
        throw new Error(`GitHub returned an empty blob SHA for ${file.path}`);
      }
      tree.push({
        path: normalizeRepoPath(file.path),
        mode: "100644",
        type: "blob",
        sha: blob.sha
      });
    }
    for (const path of deletes) {
      tree.push({
        path: normalizeRepoPath(path),
        mode: "100644",
        type: "blob",
        sha: null
      });
    }
    step++;
    onProgress?.(step, totalSteps);
    log(`Creating incremental tree (${tree.length} entries) on ${baseTreeSha.slice(0, 7)}`);
    const newTree = await githubRequestWithRetry(
      token,
      "POST",
      `/repos/${owner}/${repo}/git/trees`,
      { base_tree: baseTreeSha, tree },
      { retryStatuses: GIT_RETRY_STATUSES }
    );
    log(`Creating content update commit on ${branch}@${parentSha.slice(0, 7)}`);
    const commit = await githubRequestWithRetry(
      token,
      "POST",
      `/repos/${owner}/${repo}/git/commits`,
      {
        message,
        tree: newTree.sha,
        parents: [parentSha]
      },
      { retryStatuses: GIT_RETRY_STATUSES }
    );
    await updateBranchRef(token, repoInfo.node_id, branch, commit.sha, owner, repo);
    return commit.sha;
  };
  try {
    return await attemptCommit();
  } catch (error) {
    if (error instanceof GitHubApiError && error.status === 409) {
      logWarn("Content update commit conflict (409), retrying with fresh parent");
      step = 0;
      return await attemptCommit();
    }
    throw error;
  }
}
async function getBranchRef(token, owner, repo, branch) {
  try {
    return await githubRequest(
      token,
      "GET",
      `/repos/${owner}/${repo}/git/ref/heads/${branch}`
    );
  } catch (error) {
    if (isMissingBranchRefError(error)) {
      return null;
    }
    throw error;
  }
}
async function createCommitAndUpdateBranch(token, owner, repo, treeSha, message) {
  const repoInfo = await getRepo(token, owner, repo);
  const branch = repoInfo.default_branch || "main";
  const branchRef = await getBranchRef(token, owner, repo, branch);
  const commitBody = {
    message,
    tree: treeSha
  };
  if (branchRef) {
    commitBody.parents = [branchRef.object.sha];
    log(`Creating commit on top of ${branch}@${branchRef.object.sha.slice(0, 7)}`);
  } else {
    log(`Creating initial commit for ${branch}`);
  }
  const commit = await githubRequestWithRetry(
    token,
    "POST",
    `/repos/${owner}/${repo}/git/commits`,
    commitBody,
    { retryStatuses: GIT_RETRY_STATUSES }
  );
  if (branchRef) {
    await updateBranchRef(
      token,
      repoInfo.node_id,
      branch,
      commit.sha,
      owner,
      repo
    );
    return commit.sha;
  }
  log(`Creating branch ${branch} at ${commit.sha.slice(0, 7)}`);
  try {
    await githubRequestWithRetry(
      token,
      "POST",
      `/repos/${owner}/${repo}/git/refs`,
      { ref: `refs/heads/${branch}`, sha: commit.sha },
      { retryStatuses: GIT_RETRY_STATUSES }
    );
  } catch (error) {
    if (error instanceof GitHubApiError && [404, 409, 422].includes(error.status)) {
      logWarn(`POST ref failed (${error.status}), falling back to branch update`);
      await updateBranchRef(
        token,
        repoInfo.node_id,
        branch,
        commit.sha,
        owner,
        repo
      );
    } else {
      throw error;
    }
  }
  return commit.sha;
}
async function updateBranchRef(token, repositoryNodeId, branch, commitSha, owner, repo) {
  await sleep(500);
  const currentRef = await getBranchRef(token, owner, repo, branch);
  if (currentRef?.node_id) {
    await updateBranchRefGraphQL(token, currentRef.node_id, commitSha);
  } else {
    await createBranchRefGraphQL(token, repositoryNodeId, branch, commitSha);
  }
  log(`Verified ${branch} now points to ${commitSha.slice(0, 7)} (via GraphQL)`);
}
async function branchExists(token, owner, repo, branch) {
  try {
    await githubRequest(token, "GET", `/repos/${owner}/${repo}/git/ref/heads/${branch}`);
    return true;
  } catch (error) {
    if (isMissingBranchRefError(error)) {
      return false;
    }
    throw error;
  }
}
function normalizeRepoPath(path) {
  const normalized = path.replace(/\\/g, "/").replace(/^\/+/, "").replace(/\/+$/, "");
  if (!normalized) {
    throw new Error("Encountered an empty repository path while preparing upload.");
  }
  if (normalized.split("/").some((segment) => segment === "" || segment === "." || segment === "..")) {
    throw new Error(`Invalid repository path: ${path}`);
  }
  return normalized;
}
function dedupeBlobEntries(entries) {
  const byPath = /* @__PURE__ */ new Map();
  for (const entry of entries) {
    byPath.set(entry.path, entry);
  }
  return [...byPath.values()];
}
function buildTreeNode(entries) {
  const root = { files: [], children: /* @__PURE__ */ new Map() };
  for (const entry of entries) {
    const parts = entry.path.split("/");
    let node = root;
    for (let i = 0; i < parts.length - 1; i++) {
      const part = parts[i];
      let child = node.children.get(part);
      if (!child) {
        child = { files: [], children: /* @__PURE__ */ new Map() };
        node.children.set(part, child);
      }
      node = child;
    }
    const fileName = parts[parts.length - 1];
    const existing = node.files.find((file) => file.name === fileName);
    if (existing) {
      logWarn(`Duplicate path in upload set, using latest blob: ${entry.path}`);
      existing.sha = entry.sha;
    } else {
      node.files.push({ name: fileName, sha: entry.sha });
    }
  }
  return root;
}
async function createHierarchicalTree(token, owner, repo, entries) {
  const uniqueEntries = dedupeBlobEntries(entries);
  const root = buildTreeNode(uniqueEntries);
  return createTreeNode(token, owner, repo, root, "(root)");
}
async function createTreeNode(token, owner, repo, node, label) {
  const tree = [];
  for (const [name, child] of [...node.children.entries()].sort(([a], [b]) => a.localeCompare(b))) {
    const childSha = await createTreeNode(token, owner, repo, child, `${label}/${name}`);
    tree.push({
      path: name,
      mode: "040000",
      type: "tree",
      sha: childSha
    });
  }
  for (const file of [...node.files].sort((a, b) => a.name.localeCompare(b.name))) {
    tree.push({
      path: file.name,
      mode: "100644",
      type: "blob",
      sha: file.sha
    });
  }
  if (tree.length === 0) {
    throw new Error(`No tree entries generated for ${label}`);
  }
  log(`Creating tree for ${label} (${tree.length} entries)`);
  const response = await githubRequestWithRetry(
    token,
    "POST",
    `/repos/${owner}/${repo}/git/trees`,
    { tree },
    { retryStatuses: GIT_RETRY_STATUSES }
  );
  return response.sha;
}
function uint8ArrayToBase64(bytes) {
  let binary = "";
  const chunk = 32768;
  for (let i = 0; i < bytes.length; i += chunk) {
    binary += String.fromCharCode(...bytes.subarray(i, i + chunk));
  }
  return btoa(binary);
}

// src/utils/path.ts
function extname(filePath) {
  const name = filePath.split(/[/\\]/).pop() ?? filePath;
  const index = name.lastIndexOf(".");
  if (index <= 0) {
    return "";
  }
  return name.slice(index);
}

// src/toolchain/embeddedAssets.ts
var EMBEDDED_ASSETS_BUNDLE = "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";

// src/utils/binary.ts
var zlibImport = __toESM(require("zlib"), 1);
var nodeZlib = zlibImport;
function asUint8Array(value) {
  if (!(value instanceof Uint8Array)) {
    throw new Error("Expected binary file contents");
  }
  return value;
}
function decodeBase64(encoded) {
  const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  const normalized = encoded.replace(/=+$/, "");
  const bytes = new Uint8Array(Math.floor(normalized.length * 3 / 4));
  let byteIndex = 0;
  let bits = 0;
  let bitCount = 0;
  for (const char of normalized) {
    const value = alphabet.indexOf(char);
    if (value < 0) {
      continue;
    }
    bits = bits << 6 | value;
    bitCount += 6;
    if (bitCount >= 8) {
      bitCount -= 8;
      bytes[byteIndex] = bits >> bitCount & 255;
      byteIndex++;
    }
  }
  return bytes.subarray(0, byteIndex);
}
function gunzipToUtf8(data) {
  const decompressed = nodeZlib.gunzipSync(data);
  return new TextDecoder().decode(asUint8Array(decompressed));
}

// src/toolchain/embeddedToolchain.ts
var TOOLCHAIN_PREFIX = "toolchain-quartz/";
var cachedBundle = null;
function loadEmbeddedBundle() {
  if (!EMBEDDED_ASSETS_BUNDLE) {
    return null;
  }
  if (cachedBundle) {
    return cachedBundle;
  }
  const compressed = decodeBase64(EMBEDDED_ASSETS_BUNDLE);
  const json = gunzipToUtf8(compressed);
  const bundle = parseJson(json);
  cachedBundle = new Map(bundle.files.map((file) => [file.path, file]));
  return cachedBundle;
}
function requireEmbeddedBundle() {
  const bundle = loadEmbeddedBundle();
  if (!bundle) {
    throw new Error(quartzToolchainMissingMessage());
  }
  return bundle;
}
function quartzToolchainMissingMessage() {
  return "Publish toolchain is missing.\n\nThe Quartz toolchain should be embedded in main.js. Try reloading Obsidian or reinstalling the plugin from the community store.\n\nDevelopers: run npm run build:plugin (or npm run sync:toolchain && npm run build).";
}
function loadManifestFromEmbedded(bundle) {
  const manifestFile = bundle.get(`${TOOLCHAIN_PREFIX}files.json`);
  if (!manifestFile || manifestFile.encoding !== "utf8") {
    throw new Error("Embedded Quartz toolchain is missing files.json");
  }
  const manifest = parseJson(manifestFile.data);
  return Array.isArray(manifest) ? manifest : manifest.files ?? [];
}
function loadToolchainManifest() {
  return loadManifestFromEmbedded(requireEmbeddedBundle());
}
function readToolchainText(relativePath) {
  const bundle = requireEmbeddedBundle();
  const embeddedPath = `${TOOLCHAIN_PREFIX}${relativePath}`;
  const file = bundle.get(embeddedPath);
  if (!file || file.encoding !== "utf8") {
    throw new Error(`Embedded toolchain file missing: ${relativePath}`);
  }
  return file.data;
}
function readToolchainBytes(relativePath) {
  const bundle = requireEmbeddedBundle();
  const embeddedPath = `${TOOLCHAIN_PREFIX}${relativePath}`;
  const file = bundle.get(embeddedPath);
  if (!file) {
    throw new Error(`Embedded toolchain file missing: ${relativePath}`);
  }
  if (file.encoding === "utf8") {
    return new TextEncoder().encode(file.data);
  }
  return decodeBase64(file.data);
}
function assertQuartzToolchainAvailable() {
  loadToolchainManifest();
}

// src/telemetry/ingest.ts
var TELEMETRY_INGEST_URL = "https://github-publish-telemetry.o-rouiller.workers.dev";

// src/publish/bundleToolchain.ts
var QUARTZ_CONFIG_FILE = "quartz.config.yaml";
var TEXT_EXTENSIONS2 = /* @__PURE__ */ new Set([
  ".md",
  ".mjs",
  ".ts",
  ".tsx",
  ".json",
  ".yml",
  ".yaml",
  ".html",
  ".css",
  ".gitignore"
]);
function isTextFile(relativePath) {
  if (relativePath.endsWith(".template")) {
    return true;
  }
  return TEXT_EXTENSIONS2.has(extname(relativePath));
}
function readRepoFile(relativePath) {
  const content = readToolchainBytes(relativePath);
  return {
    path: relativePath,
    content,
    encoding: isTextFile(relativePath) ? "utf-8" : "base64"
  };
}
function applyTemplate(content, context) {
  const quartzCommitSha = resolveQuartzCommitSha(context.quartzCommitSha);
  const baseUrl = `${context.owner}.github.io/${context.repoName}`;
  return content.replaceAll("{{siteName}}", context.siteName).replaceAll("{{repo}}", context.repoName).replaceAll("{{owner}}", context.owner).replaceAll("{{pageTitle}}", context.siteName).replaceAll("{{baseUrl}}", baseUrl).replaceAll("{{quartzCommitSha}}", quartzCommitSha).replaceAll("{{telemetryUrl}}", TELEMETRY_INGEST_URL);
}
function pushTemplatedFile(files, relativePath, rawContent, context) {
  const outputPath = relativePath.endsWith(".template") ? relativePath.slice(0, -".template".length) : relativePath;
  files.push({
    path: outputPath,
    content: new TextEncoder().encode(applyTemplate(rawContent, context)),
    encoding: "utf-8"
  });
}
function loadQuartzToolchain(context, overrides) {
  const filePaths = loadToolchainManifest();
  const files = [];
  for (const relativePath of filePaths) {
    const override = overrides?.[relativePath];
    if (override !== void 0) {
      files.push({
        path: relativePath,
        content: new TextEncoder().encode(override),
        encoding: "utf-8"
      });
      continue;
    }
    if (relativePath.endsWith(".template")) {
      const raw = readToolchainText(relativePath);
      pushTemplatedFile(files, relativePath, raw, context);
      continue;
    }
    const file = readRepoFile(relativePath);
    if (file.encoding === "utf-8") {
      const templated = applyTemplate(new TextDecoder().decode(file.content), context);
      files.push({
        path: file.path,
        content: new TextEncoder().encode(templated),
        encoding: "utf-8"
      });
    } else {
      files.push(file);
    }
  }
  return files;
}
function assertPublishToolchainReady() {
  assertQuartzToolchainAvailable();
}
function loadPublishToolchainFiles(context, overrides) {
  return loadQuartzToolchain(context, overrides);
}
function loadManagedToolchainFiles(context) {
  return loadPublishToolchainFiles(context).filter((file) => file.path !== QUARTZ_CONFIG_FILE);
}
function hashManagedToolchain(files) {
  const parts = [...files].sort((a, b) => a.path.localeCompare(b.path)).map((file) => `${file.path}:${hashFileContent(file.content)}`);
  return hashFileContent(new TextEncoder().encode(parts.join("\n")));
}
function getToolchainSync(site, context = publishBundleContextFromSite(site)) {
  const files = loadManagedToolchainFiles(context);
  const hash = hashManagedToolchain(files);
  if (site.toolchainHash === hash) {
    return null;
  }
  return { files, hash };
}
function resolveDefaultQuartzConfig(context) {
  return applyTemplate(readToolchainText(QUARTZ_CONFIG_FILE), context);
}
function publishBundleContextFromConfig(config, owner) {
  return {
    siteName: config.siteName,
    repoName: config.repoName,
    owner,
    quartzCommitSha: config.quartzCommitSha
  };
}
function publishBundleContextFromSite(site) {
  return {
    siteName: site.siteName,
    repoName: site.repo,
    owner: site.owner,
    quartzCommitSha: site.quartzCommitSha
  };
}

// src/publish/ensureQuartzHomePage.ts
var QUARTZ_INDEX_PATH = "content/index.md";
function ensureQuartzHomePage(contentFiles, siteName) {
  if (contentFiles.some((file) => file.path === QUARTZ_INDEX_PATH)) {
    return contentFiles;
  }
  const markdown = `---
title: ${escapeYamlString(siteName)}
---

Welcome to **${siteName}**.
`;
  return [
    ...contentFiles,
    {
      path: QUARTZ_INDEX_PATH,
      content: new TextEncoder().encode(markdown),
      encoding: "utf-8"
    }
  ];
}
function escapeYamlString(value) {
  if (/[:#{}[\],&*?|>!'"%@`]|^\s|\s$/.test(value)) {
    return `"${value.replace(/\\/g, "\\\\").replace(/"/g, '\\"')}"`;
  }
  return value;
}

// src/publish/initialPublish.ts
async function runInitialPublish(app, token, username, config, onProgress) {
  log("Starting initial publish via Git API + GraphQL updateRef", {
    contentFolder: config.contentFolder,
    repo: config.repoName
  });
  onProgress({ phase: "preparing", message: "Scanning vault folder\u2026" });
  let { files: contentFiles, warnings } = await scanVaultFolder(app.vault, config.contentFolder);
  if (contentFiles.length === 0) {
    throw new Error("No publishable files found in the selected folder.");
  }
  contentFiles = ensureQuartzHomePage(contentFiles, config.siteName);
  onProgress({ phase: "preparing", message: "Loading publish toolchain\u2026" });
  assertPublishToolchainReady();
  onProgress({
    phase: "creating-repo",
    message: config.repoMode === "create" ? "Creating repository\u2026" : "Verifying repository\u2026"
  });
  let owner = username;
  let repoName = config.repoName;
  const resolved = await resolveRepository(token, username, config.repoName, config.repoMode);
  owner = resolved.owner;
  repoName = resolved.repoName;
  if (!resolved.created && config.repoMode === "create") {
    log(`Repository ${owner}/${repoName} already exists \u2014 continuing publish`);
  }
  const bundleContext = publishBundleContextFromConfig(config, owner);
  const toolchainFiles = loadPublishToolchainFiles(bundleContext);
  const allFiles = sortUploadFiles([...toolchainFiles, ...contentFiles]);
  log(`Prepared ${contentFiles.length} content files and ${toolchainFiles.length} toolchain files`, {
    fileCount: allFiles.length,
    quartzCommitSha: bundleContext.quartzCommitSha
  });
  onProgress({ phase: "uploading", message: "Preparing repository for Git upload\u2026" });
  await ensureRepositoryReadyForGit(token, owner, repoName, (message) => {
    onProgress({ phase: "uploading", message });
  });
  onProgress({ phase: "configuring-pages", message: "Configuring GitHub Pages\u2026" });
  await enableGitHubPages(token, owner, repoName);
  onProgress({
    phase: "uploading",
    message: "Creating single Git commit\u2026",
    uploadCurrent: 0,
    uploadTotal: allFiles.length
  });
  const commitSha = await createInitialCommit(
    token,
    owner,
    repoName,
    allFiles,
    "Initial publish from Obsidian",
    (current, total) => {
      onProgress({
        phase: "uploading",
        message: `Creating Git commit (${current}/${total})\u2026`,
        uploadCurrent: current,
        uploadTotal: total
      });
    }
  );
  const manifest = buildContentManifest(allFiles);
  const configFile = toolchainFiles.find((file) => file.path === QUARTZ_CONFIG_FILE);
  const configHash = configFile ? hashFileContent(configFile.content) : void 0;
  const toolchainHash = hashManagedToolchain(
    toolchainFiles.filter((file) => file.path !== QUARTZ_CONFIG_FILE)
  );
  if (warnings.length > 0) {
    console.warn("GitHub Publish warnings:", warnings);
  }
  return {
    owner,
    repo: repoName,
    commitSha,
    manifest,
    liveUrl: `https://${owner}.github.io/${repoName}/`,
    configHash,
    toolchainHash
  };
}
function sortUploadFiles(files) {
  return [...files].sort((a, b) => a.path.localeCompare(b.path));
}

// src/publish/siteConfig.ts
var import_obsidian5 = require("obsidian");
var import_electron = require("electron");
var PLUGIN_ID = "github-publish";
var CONFIG_FILENAME = "quartz.config.yaml";
function encode(content) {
  return new TextEncoder().encode(content);
}
function safeSiteId(siteId2) {
  return siteId2.replace(/[^a-zA-Z0-9._-]/g, "_");
}
function sitesRoot(app) {
  return `${app.vault.configDir}/plugins/${PLUGIN_ID}/sites`;
}
function siteDir(app, siteId2) {
  return `${sitesRoot(app)}/${safeSiteId(siteId2)}`;
}
function siteConfigPath(app, siteId2) {
  return `${siteDir(app, siteId2)}/${CONFIG_FILENAME}`;
}
function absoluteSiteConfigPath(app, siteId2) {
  const adapter = app.vault.adapter;
  if (!(adapter instanceof import_obsidian5.FileSystemAdapter)) {
    return null;
  }
  return adapter.getFullPath(siteConfigPath(app, siteId2));
}
async function ensureSiteConfigOnDisk(app, siteId2, content) {
  await writeSiteConfigOverride(app, siteId2, content);
  const absolute = absoluteSiteConfigPath(app, siteId2);
  if (!absolute) {
    throw new Error("Reveal in Finder requires a local vault on disk.");
  }
  return absolute;
}
function parentDirectory(filePath) {
  const lastSep = Math.max(filePath.lastIndexOf("/"), filePath.lastIndexOf("\\"));
  if (lastSep <= 0) {
    return filePath;
  }
  return filePath.slice(0, lastSep);
}
function openParentFolderInFileManager(absolutePath) {
  if (!import_obsidian5.Platform.isDesktopApp) {
    throw new Error("Open in file manager is only available in the desktop app.");
  }
  const parentDir = parentDirectory(absolutePath);
  void import_electron.shell.openPath(parentDir);
}
function revealInFileManagerLabel() {
  if (import_obsidian5.Platform.isMacOS) {
    return "Show in Finder";
  }
  if (import_obsidian5.Platform.isWin) {
    return "Show in Explorer";
  }
  return "Show in file manager";
}
async function ensureDir(app, dir) {
  if (!await app.vault.adapter.exists(dir)) {
    await app.vault.adapter.mkdir(dir);
  }
}
async function readSiteConfigOverride(app, siteId2) {
  const path = siteConfigPath(app, siteId2);
  if (!await app.vault.adapter.exists(path)) {
    return null;
  }
  return app.vault.adapter.read(path);
}
async function writeSiteConfigOverride(app, siteId2, content) {
  await ensureDir(app, sitesRoot(app));
  await ensureDir(app, siteDir(app, siteId2));
  await app.vault.adapter.write(siteConfigPath(app, siteId2), content);
}
async function removeSiteConfigOverride(app, siteId2) {
  const path = siteConfigPath(app, siteId2);
  if (await app.vault.adapter.exists(path)) {
    await app.vault.adapter.remove(path);
  }
}
function baselineConfigHash(site) {
  if (site.configHash) {
    return site.configHash;
  }
  const defaultConfig = resolveDefaultQuartzConfig(publishBundleContextFromSite(site));
  return hashFileContent(encode(defaultConfig));
}
async function getSiteConfigChange(app, site) {
  const override = await readSiteConfigOverride(app, site.id);
  if (override === null) {
    return null;
  }
  const hash = hashFileContent(encode(override));
  if (hash === baselineConfigHash(site)) {
    return null;
  }
  return { content: override, hash };
}

// src/publish/publishChanges.ts
async function runPublishChanges(app, token, site, onProgress) {
  const { owner, repo, contentFolder } = site;
  if (!owner || !repo || !contentFolder) {
    throw new Error("Published site configuration is incomplete.");
  }
  log("Starting incremental publish", { owner, repo, contentFolder });
  onProgress({ phase: "preparing", message: "Scanning vault for changes\u2026" });
  assertPublishToolchainReady();
  const { files: contentFiles, warnings } = await scanVaultFolder(app.vault, contentFolder);
  const diff = diffAgainstManifest(site.manifest, contentFiles);
  const configChange = await getSiteConfigChange(app, site);
  const toolchainSync = getToolchainSync(site, publishBundleContextFromSite(site));
  if (countDiffChanges(diff) === 0 && !configChange && !toolchainSync) {
    throw new Error("No unpublished changes found.");
  }
  const changedFiles = [...diff.adds, ...diff.updates];
  const uploadFiles = [...changedFiles];
  if (configChange) {
    uploadFiles.push({
      path: QUARTZ_CONFIG_FILE,
      content: new TextEncoder().encode(configChange.content),
      encoding: "utf-8"
    });
  }
  if (toolchainSync) {
    uploadFiles.push(...toolchainSync.files);
  }
  const summary = combineChangeSummary(diff, Boolean(configChange), Boolean(toolchainSync));
  log(`Publishing changes: ${summary}`);
  onProgress({
    phase: "uploading",
    message: `Uploading ${uploadFiles.length} changed file(s)\u2026`,
    uploadCurrent: 0,
    uploadTotal: uploadFiles.length + 1
  });
  const commitMessage = buildCommitMessage(diff, Boolean(configChange), Boolean(toolchainSync));
  const commitSha = await createContentUpdateCommit(
    token,
    owner,
    repo,
    uploadFiles,
    diff.deletes,
    commitMessage,
    (current, total) => {
      onProgress({
        phase: "uploading",
        message: current <= uploadFiles.length ? `Uploading changed files (${current}/${uploadFiles.length})\u2026` : "Creating Git commit\u2026",
        uploadCurrent: current,
        uploadTotal: total
      });
    }
  );
  const manifest = mergeManifestAfterPublish(site.manifest, diff);
  if (warnings.length > 0) {
    console.warn("GitHub Publish warnings:", warnings);
  }
  return {
    owner,
    repo,
    commitSha,
    manifest,
    liveUrl: `https://${owner}.github.io/${repo}/`,
    configHash: configChange ? configChange.hash : site.configHash,
    toolchainHash: toolchainSync ? toolchainSync.hash : site.toolchainHash
  };
}
function combineChangeSummary(diff, configChanged, toolchainChanged) {
  const contentChanges = countDiffChanges(diff);
  if (!configChanged && !toolchainChanged) {
    return formatDiffSummary(diff);
  }
  const parts = [];
  if (contentChanges > 0) {
    parts.push(formatDiffSummary(diff));
  }
  if (configChanged) {
    parts.push(contentChanges === 0 && !toolchainChanged ? "Quartz config changed" : "config changed");
  }
  if (toolchainChanged) {
    parts.push(
      contentChanges === 0 && !configChanged ? "Toolchain updated" : "toolchain updated"
    );
  }
  return parts.join(", ");
}
function buildCommitMessage(diff, configChanged, toolchainChanged) {
  const changeCount = countDiffChanges(diff);
  if (changeCount === 0 && configChanged && !toolchainChanged) {
    return "Update Quartz configuration";
  }
  if (changeCount === 0 && toolchainChanged && !configChanged) {
    return "Update publish toolchain";
  }
  if (changeCount === 0 && configChanged && toolchainChanged) {
    return "Update Quartz configuration and publish toolchain";
  }
  const base = changeCount === 1 ? "Publish vault updates" : `Publish vault updates (${changeCount} files)`;
  const extras = [];
  if (configChanged) extras.push("Quartz config");
  if (toolchainChanged) extras.push("toolchain");
  return extras.length > 0 ? `${base} + ${extras.join(" + ")}` : base;
}
async function detectUnpublishedChanges(app, site) {
  if (!site.contentFolder) return null;
  const { files } = await scanVaultFolder(app.vault, site.contentFolder);
  const diff = diffAgainstManifest(site.manifest, files);
  const configChanged = await getSiteConfigChange(app, site) !== null;
  const toolchainChanged = getToolchainSync(site) !== null;
  return {
    diff,
    summary: combineChangeSummary(diff, configChanged, toolchainChanged),
    configChanged,
    toolchainChanged
  };
}

// src/ui/ProgressModal.ts
var import_obsidian7 = require("obsidian");

// src/ui/dom.ts
var import_obsidian6 = require("obsidian");
var SVG_NS = "http://www.w3.org/2000/svg";
function appendCopyIcon(button) {
  const svg = activeDocument.createElementNS(SVG_NS, "svg");
  svg.setAttribute("width", "16");
  svg.setAttribute("height", "16");
  svg.setAttribute("viewBox", "0 0 24 24");
  svg.setAttribute("fill", "none");
  svg.setAttribute("stroke", "currentColor");
  svg.setAttribute("stroke-width", "2");
  svg.setAttribute("stroke-linecap", "round");
  svg.setAttribute("stroke-linejoin", "round");
  const rect = activeDocument.createElementNS(SVG_NS, "rect");
  rect.setAttribute("width", "14");
  rect.setAttribute("height", "14");
  rect.setAttribute("x", "8");
  rect.setAttribute("y", "8");
  rect.setAttribute("rx", "2");
  rect.setAttribute("ry", "2");
  svg.appendChild(rect);
  const path = activeDocument.createElementNS(SVG_NS, "path");
  path.setAttribute("d", "M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2");
  svg.appendChild(path);
  button.appendChild(svg);
}
function appendTrashIcon(button) {
  const svg = activeDocument.createElementNS(SVG_NS, "svg");
  svg.setAttribute("width", "16");
  svg.setAttribute("height", "16");
  svg.setAttribute("viewBox", "0 0 24 24");
  svg.setAttribute("fill", "none");
  svg.setAttribute("stroke", "currentColor");
  svg.setAttribute("stroke-width", "2");
  svg.setAttribute("stroke-linecap", "round");
  svg.setAttribute("stroke-linejoin", "round");
  const path = activeDocument.createElementNS(SVG_NS, "path");
  path.setAttribute("d", "M3 6h18");
  svg.appendChild(path);
  const path2 = activeDocument.createElementNS(SVG_NS, "path");
  path2.setAttribute(
    "d",
    "M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"
  );
  svg.appendChild(path2);
  const path3 = activeDocument.createElementNS(SVG_NS, "path");
  path3.setAttribute("d", "M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2");
  svg.appendChild(path3);
  button.appendChild(svg);
}
function asElement(value) {
  return value;
}
function childDiv(host, opts) {
  const el = host.createDiv(opts);
  return asElement(el);
}
function childSpan(host, opts) {
  const el = host.createSpan(opts);
  return asElement(el);
}
function childEl(host, tag, opts) {
  const el = host.createEl(tag, opts);
  return asElement(el);
}
function addCopyButton(host, text, options) {
  const copyBtn = childEl(host, "button", {
    cls: "clickable-icon github-publish-copy-url"
  });
  copyBtn.setAttr("aria-label", options?.ariaLabel ?? "Copy to clipboard");
  appendCopyIcon(copyBtn);
  copyBtn.addEventListener("click", () => {
    void navigator.clipboard.writeText(text).then(
      () => new import_obsidian6.Notice(options?.successNotice ?? "Copied to clipboard"),
      () => new import_obsidian6.Notice("Could not copy to clipboard")
    );
  });
  return copyBtn;
}
function addTrashButton(host, options) {
  const trashBtn = childEl(host, "button", {
    cls: "clickable-icon github-publish-untrack-button"
  });
  trashBtn.setAttr("aria-label", options.ariaLabel ?? "Stop tracking site");
  appendTrashIcon(trashBtn);
  trashBtn.addEventListener("click", options.onClick);
  return trashBtn;
}

// src/ui/ProgressModal.ts
var ProgressModal = class _ProgressModal extends import_obsidian7.Modal {
  constructor(app, token, publishTask, onComplete, options) {
    super(app);
    this.token = token;
    this.publishTask = publishTask;
    this.onComplete = onComplete;
    this.options = options;
    this.state = {
      phase: "preparing",
      message: "Starting\u2026"
    };
    this.lastActivePhase = "preparing";
    this.runningInBackground = false;
    this.actionsListUrl = options?.actionsListUrl;
  }
  onOpen() {
    const { contentEl } = this;
    contentEl.empty();
    contentEl.addClass("github-publish-modal");
    if (this.options?.previewState) {
      this.state = { ...this.options.previewState };
      this.lastActivePhase = this.state.phase === "error" ? "preparing" : this.state.phase;
      this.render();
      return;
    }
    this.render();
    void this.run();
  }
  /** Open the success screen with mock data for UI development. */
  static openDonePreview(app, options) {
    new _ProgressModal(
      app,
      "",
      async () => {
        throw new Error("ProgressModal preview does not run publish.");
      },
      () => Promise.resolve(),
      {
        mode: options.mode,
        previewState: {
          phase: "done",
          message: options.message ?? "Your site is live!",
          liveUrl: options.liveUrl
        }
      }
    ).open();
  }
  async run() {
    try {
      const result = await this.publishTask((update) => {
        if (update.phase && update.phase !== "error") {
          this.lastActivePhase = update.phase;
        }
        this.state = { ...this.state, ...update };
        if (!this.runningInBackground) {
          this.render();
        }
      });
      this.actionsListUrl = repoActionsUrl(result.owner, result.repo);
      this.state = {
        phase: "waiting-build",
        message: "Waiting for GitHub Actions build\u2026"
      };
      if (!this.runningInBackground) {
        this.render();
      }
      await pollWorkflowRun(
        this.token,
        result.owner,
        result.repo,
        result.commitSha,
        (run) => {
          if (!run) {
            this.state = {
              phase: "waiting-build",
              message: "Waiting for workflow to start\u2026"
            };
          } else if (run.status !== "completed") {
            this.state = {
              phase: "waiting-deploy",
              message: "Building and deploying site\u2026",
              actionsUrl: run.html_url
            };
          }
          if (!this.runningInBackground) {
            this.render();
          }
        }
      );
      this.state = {
        phase: "done",
        message: "Your site is live!",
        liveUrl: result.liveUrl
      };
      if (!this.runningInBackground) {
        this.render();
      }
      await this.onComplete(result);
      if (this.runningInBackground) {
        new import_obsidian7.Notice(`GitHub Publish: site updated \u2014 ${result.liveUrl}`);
      }
    } catch (error) {
      this.state = {
        phase: "error",
        message: "Publish failed",
        error: error instanceof Error ? error.message : String(error)
      };
      if (!this.runningInBackground) {
        this.render();
      } else {
        new import_obsidian7.Notice(
          `GitHub Publish failed: ${error instanceof Error ? error.message : String(error)}`
        );
      }
    } finally {
      this.options?.onFinished?.();
    }
  }
  getPhases() {
    if (this.options?.mode === "incremental") {
      return [
        { phase: "preparing", label: "Detect changes" },
        { phase: "uploading", label: "Upload changed files" },
        { phase: "waiting-build", label: "Build site (GitHub Actions)" },
        { phase: "waiting-deploy", label: "Deploy to GitHub Pages" },
        { phase: "done", label: "Site is live" }
      ];
    }
    return [
      { phase: "preparing", label: "Prepare files" },
      { phase: "creating-repo", label: "Create repository" },
      { phase: "configuring-pages", label: "Configure GitHub Pages" },
      { phase: "uploading", label: "Create single Git commit" },
      { phase: "waiting-build", label: "Build site (GitHub Actions)" },
      { phase: "waiting-deploy", label: "Deploy to GitHub Pages" },
      { phase: "done", label: "Site is live" }
    ];
  }
  render() {
    const { contentEl } = this;
    contentEl.empty();
    contentEl.addClass("github-publish-modal");
    const title = this.options?.mode === "incremental" ? "Publishing changes to GitHub Pages" : "Publishing to GitHub Pages";
    childEl(contentEl, "h2", { text: title });
    this.renderSubtitle(contentEl);
    const steps = childDiv(contentEl, { cls: "github-publish-steps" });
    const phases = this.getPhases();
    const order = phases.map((p) => p.phase);
    const failedIndex = this.state.phase === "error" ? order.indexOf(this.lastActivePhase) : -1;
    const currentIndex = this.state.phase === "error" ? failedIndex : order.indexOf(this.state.phase);
    for (let i = 0; i < phases.length; i++) {
      const phase = phases[i];
      if (!phase) continue;
      const { label } = phase;
      const row = childDiv(steps, { cls: "github-publish-step" });
      const icon = childSpan(row, { cls: "github-publish-step-icon" });
      if (this.state.phase === "error" && i === failedIndex) {
        row.addClass("github-publish-step-error");
        icon.setText("\u2717");
      } else if (i < currentIndex || this.state.phase === "done") {
        row.addClass("github-publish-step-done");
        icon.setText("\u2713");
      } else if (i === currentIndex) {
        row.addClass("github-publish-step-active");
        icon.setText("\u2026");
      } else {
        row.addClass("github-publish-step-pending");
        icon.setText("\u25CB");
      }
      childSpan(row, { text: label });
    }
    childEl(contentEl, "p", { text: this.state.message });
    if (this.state.uploadTotal) {
      const progressLabel = this.options?.mode === "incremental" ? "Processed" : "Prepared";
      childEl(contentEl, "p", {
        text: `${progressLabel} ${String(this.state.uploadCurrent ?? 0)} / ${String(this.state.uploadTotal)} files`
      });
    }
    if (this.state.phase === "done" && this.state.liveUrl) {
      this.renderLiveUrlRow(contentEl, this.state.liveUrl);
      new import_obsidian7.Setting(contentEl).addButton(
        (btn) => btn.setButtonText("Open site").setCta().onClick(() => window.open(this.state.liveUrl))
      ).addButton((btn) => btn.setButtonText("Close").onClick(() => this.close()));
      return;
    }
    if (this.state.phase === "error") {
      const errorText = this.state.error ?? "";
      const copyText = [this.state.message, errorText].filter(Boolean).join("\n\n");
      const errorRow = childDiv(contentEl, { cls: "github-publish-error-row" });
      childEl(errorRow, "p", { cls: "github-publish-step-error", text: errorText });
      addCopyButton(errorRow, copyText, {
        ariaLabel: "Copy error message",
        successNotice: "Error copied to clipboard"
      });
      if (this.state.actionsUrl) {
        new import_obsidian7.Setting(contentEl).addButton(
          (btn) => btn.setButtonText("View Actions run").onClick(() => window.open(this.state.actionsUrl))
        );
      }
      new import_obsidian7.Setting(contentEl).addButton((btn) => btn.setButtonText("Close").onClick(() => this.close()));
      return;
    }
    new import_obsidian7.Setting(contentEl).addButton(
      (btn) => btn.setButtonText("Continue in background").onClick(() => {
        this.runningInBackground = true;
        new import_obsidian7.Notice("Publishing in background \u2014 you will be notified when it finishes.");
        this.close();
      })
    );
  }
  renderSubtitle(container) {
    const subtitle = childDiv(container, { cls: "github-publish-progress-subtitle" });
    childEl(subtitle, "p", {
      text: "It can take up to a few minutes, especially the first time."
    });
    if (!this.actionsListUrl) {
      return;
    }
    const linkRow = childDiv(subtitle, { cls: "github-publish-actions-link-row" });
    const link = childEl(linkRow, "a", {
      cls: "github-publish-actions-link",
      href: this.actionsListUrl,
      text: "monitor github actions"
    });
    link.target = "_blank";
    link.rel = "noopener noreferrer";
  }
  renderLiveUrlRow(container, liveUrl) {
    const row = childDiv(container, { cls: "github-publish-live-url-row" });
    const link = childEl(row, "a", {
      cls: "github-publish-live-link",
      href: liveUrl,
      text: liveUrl
    });
    link.target = "_blank";
    link.rel = "noopener noreferrer";
    addCopyButton(row, liveUrl, {
      ariaLabel: "Copy site URL",
      successNotice: "Site URL copied to clipboard"
    });
  }
};

// src/publish/startPublish.ts
function saveSetupConfig(plugin, config) {
  plugin.settings.savedSetup = config;
  void plugin.saveSettings();
}
function startPublish(plugin, config) {
  const token = plugin.settings.accessToken;
  const username = plugin.settings.githubUsername;
  if (!token || !username) {
    new import_obsidian8.Notice("Connect to GitHub in plugin settings first.");
    return;
  }
  const publishConfig = withTemplateSettings(config ?? plugin.settings.savedSetup, plugin);
  if (!publishConfig) {
    new import_obsidian8.Notice("No saved publish setup. Run the setup wizard first.");
    return;
  }
  saveSetupConfig(plugin, publishConfig);
  const publishingId = siteId(username, publishConfig.repoName);
  if (plugin.isSitePublishing(publishingId)) {
    new import_obsidian8.Notice("Publish already in progress for this site.");
    return;
  }
  plugin.markSitePublishing(publishingId);
  const progress = new ProgressModal(
    plugin.app,
    token,
    (onProgress) => runInitialPublish(
      plugin.app,
      token,
      username,
      publishConfig,
      onProgress
    ),
    async (result) => {
      const site = publishedSiteFromPublishResult(
        publishConfig,
        result.owner,
        result.repo,
        result.commitSha,
        result.manifest,
        result.configHash,
        result.toolchainHash
      );
      plugin.settings.publishedSites = upsertPublishedSite(plugin.settings.publishedSites, site);
      plugin.settings.savedSetup = null;
      await plugin.saveSettings();
      new import_obsidian8.Notice(`Site published: ${result.liveUrl}`);
    },
    {
      mode: "full",
      actionsListUrl: repoActionsUrl(username, publishConfig.repoName),
      onFinished: () => plugin.clearSitePublishing(publishingId)
    }
  );
  progress.open();
}
function startPublishChanges(plugin, site) {
  log("Publish changes requested", { siteId: site.id });
  const token = plugin.settings.accessToken;
  if (!token) {
    new import_obsidian8.Notice("Connect to GitHub in plugin settings first.");
    return;
  }
  if (!isPublishedSite(site)) {
    new import_obsidian8.Notice("Complete initial publish before publishing changes.");
    return;
  }
  if (plugin.isSitePublishing(site.id)) {
    new import_obsidian8.Notice("Publish already in progress for this site.");
    return;
  }
  plugin.markSitePublishing(site.id);
  const progress = new ProgressModal(
    plugin.app,
    token,
    (onProgress) => runPublishChanges(plugin.app, token, site, onProgress),
    async (result) => {
      plugin.settings.publishedSites = updatePublishedSite(
        plugin.settings.publishedSites,
        site.id,
        {
          lastPublishedCommitSha: result.commitSha,
          manifest: result.manifest,
          configHash: result.configHash,
          toolchainHash: result.toolchainHash
        }
      );
      await plugin.saveSettings();
      new import_obsidian8.Notice(`Changes published: ${result.liveUrl}`);
    },
    {
      mode: "incremental",
      actionsListUrl: repoActionsUrl(site.owner, site.repo),
      onFinished: () => plugin.clearSitePublishing(site.id)
    }
  );
  progress.open();
}
function getPublishableSites(plugin) {
  return plugin.settings.publishedSites.filter(isPublishedSite);
}
function withTemplateSettings(config, plugin) {
  if (!config) return null;
  return {
    ...config,
    quartzCommitSha: config.quartzCommitSha ?? plugin.settings.quartzCommitSha ?? resolveQuartzCommitSha(null)
  };
}

// src/ui/FolderTree.ts
var import_obsidian9 = require("obsidian");
var FolderTree = class {
  constructor(app, container, options) {
    this.app = app;
    this.container = container;
    this.options = options;
  }
  render() {
    this.container.empty();
    const tree = childDiv(this.container, { cls: "github-publish-folder-tree" });
    const root = this.app.vault.getRoot();
    const topFolders = root.children.filter((child) => child instanceof import_obsidian9.TFolder).sort((a, b) => a.name.localeCompare(b.name, void 0, { sensitivity: "base" }));
    for (const folder of topFolders) {
      this.renderFolder(tree, folder, 0);
    }
    if (topFolders.length === 0) {
      childEl(tree, "p", {
        cls: "github-publish-folder-tree-empty",
        text: "No folders found in this vault."
      });
    }
  }
  renderFolder(parent, folder, depth) {
    const subfolders = folder.children.filter((child) => child instanceof import_obsidian9.TFolder);
    const hasSubfolders = subfolders.length > 0;
    const isExpanded = this.options.expandedPaths.has(folder.path);
    const isSelected = this.options.selectedPath === folder.path;
    const row = childDiv(parent, {
      cls: `github-publish-folder-row${isSelected ? " is-selected" : ""}`
    });
    row.style.setProperty("--folder-depth", String(depth));
    const toggle = childSpan(row, { cls: "github-publish-folder-toggle" });
    if (hasSubfolders) {
      const btn = childEl(toggle, "button", {
        type: "button",
        cls: "github-publish-folder-chevron",
        text: isExpanded ? "\u25BE" : "\u25B8"
      });
      btn.setAttribute("aria-label", isExpanded ? "Collapse folder" : "Expand folder");
      btn.addEventListener("click", (event) => {
        event.stopPropagation();
        this.options.onToggleExpand(folder.path);
      });
    }
    const label = childSpan(row, {
      cls: "github-publish-folder-label",
      text: folder.name
    });
    label.addEventListener("click", () => {
      this.options.onSelect(folder.path);
    });
    if (hasSubfolders && isExpanded) {
      const children = childDiv(parent, { cls: "github-publish-folder-children" });
      for (const child of subfolders.sort(
        (a, b) => a.name.localeCompare(b.name, void 0, { sensitivity: "base" })
      )) {
        this.renderFolder(children, child, depth + 1);
      }
    }
  }
};

// src/ui/SetupModal.ts
var CREATE_REPO_NAME_PATTERN = /^[a-z0-9][a-z0-9-]*$/;
function humanizeFolderSegment(segment) {
  const spaced = segment.replace(/[-_]+/g, " ").trim();
  if (!spaced) return "";
  if (/[A-Z]/.test(spaced.slice(1))) {
    return spaced;
  }
  return spaced.replace(/\b\w/g, (char) => char.toUpperCase());
}
function suggestSiteNameFromFolder(folderPath, vaultName) {
  if (!folderPath) {
    const name = vaultName?.trim();
    return name ? humanizeFolderSegment(name) || name : "My Notes";
  }
  const segment = folderPath.split("/").filter(Boolean).pop() ?? folderPath;
  return humanizeFolderSegment(segment) || segment;
}
function suggestRepoNameFromSiteName(siteName) {
  let name = siteName.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/[^a-z0-9\s-]/g, "").trim().replace(/\s+/g, "-").replace(/-+/g, "-").replace(/^-+|-+$/g, "");
  if (!name) {
    name = "my-notes-site";
  }
  if (!/^[a-z0-9]/.test(name)) {
    name = `notes-${name}`.replace(/-+/g, "-").replace(/^-+|-+$/g, "");
  }
  return name.slice(0, 100);
}
var SetupModal = class extends import_obsidian10.Modal {
  constructor(app, plugin) {
    super(app);
    this.plugin = plugin;
    this.step = 1;
    this.siteName = "";
    this.contentFolder = "";
    this.repoMode = "create";
    this.repoName = "";
    this.siteNameEdited = false;
    this.repoNameEdited = false;
    this.isPublishing = false;
    this.expandedFolders = /* @__PURE__ */ new Set();
    this.repoNameAvailability = "idle";
    this.repoNameAvailabilityMessage = "";
    this.repoNameCheckId = 0;
    this.repoNameCheckTimer = null;
    this.repoAvailabilityEl = null;
    this.keydownHandler = null;
  }
  onOpen() {
    if (!this.plugin.settings.accessToken) {
      new import_obsidian10.Notice("Connect to GitHub in plugin settings first.");
      this.close();
      return;
    }
    this.siteName = "";
    this.contentFolder = "";
    this.repoMode = "create";
    this.repoName = "";
    this.siteNameEdited = false;
    this.repoNameEdited = false;
    this.resetRepoNameAvailability();
    this.keydownHandler = (event) => {
      this.handleWizardKeydown(event);
    };
    activeDocument.addEventListener("keydown", this.keydownHandler, true);
    this.render();
  }
  handleWizardKeydown(event) {
    if (event.key !== "Enter") {
      return;
    }
    if (event.shiftKey || event.altKey || event.ctrlKey || event.metaKey || event.isComposing) {
      return;
    }
    if (this.isPublishing) {
      return;
    }
    if (!this.modalEl.contains(event.target)) {
      return;
    }
    const target = event.target;
    if (target instanceof HTMLTextAreaElement) {
      return;
    }
    if (target instanceof HTMLButtonElement && !target.classList.contains("mod-cta")) {
      return;
    }
    event.preventDefault();
    this.submitWizard();
  }
  submitWizard() {
    if (this.isPublishing) {
      return;
    }
    if (this.step === 3 && this.repoMode === "create") {
      void this.advanceFromRepoStep();
      return;
    }
    this.advanceStep();
  }
  onClose() {
    this.clearRepoNameCheckTimer();
    if (this.keydownHandler) {
      activeDocument.removeEventListener("keydown", this.keydownHandler, true);
      this.keydownHandler = null;
    }
    this.contentEl.empty();
  }
  resetRepoNameAvailability() {
    this.repoNameAvailability = "idle";
    this.repoNameAvailabilityMessage = "";
    this.repoNameCheckId++;
  }
  clearRepoNameCheckTimer() {
    if (this.repoNameCheckTimer !== null) {
      window.clearTimeout(this.repoNameCheckTimer);
      this.repoNameCheckTimer = null;
    }
  }
  scheduleRepoNameCheck(immediate = false) {
    this.clearRepoNameCheckTimer();
    if (this.repoMode !== "create" || this.step !== 3) {
      return;
    }
    if (immediate) {
      void this.checkRepoNameAvailability();
      return;
    }
    this.repoNameCheckTimer = window.setTimeout(() => {
      this.repoNameCheckTimer = null;
      void this.checkRepoNameAvailability();
    }, 400);
  }
  async checkRepoNameAvailability() {
    if (this.repoMode !== "create") {
      this.resetRepoNameAvailability();
      this.updateRepoAvailabilityElement();
      return true;
    }
    const repoName = this.repoName.trim();
    if (!repoName || !CREATE_REPO_NAME_PATTERN.test(repoName)) {
      this.repoNameAvailability = "idle";
      this.repoNameAvailabilityMessage = "";
      this.updateRepoAvailabilityElement();
      return false;
    }
    const token = this.plugin.settings.accessToken;
    const username = this.plugin.settings.githubUsername;
    if (!token || !username) {
      return false;
    }
    const checkId = ++this.repoNameCheckId;
    this.repoNameAvailability = "checking";
    this.repoNameAvailabilityMessage = "Checking repository name\u2026";
    this.updateRepoAvailabilityElement();
    try {
      const exists = await userRepoExists(token, username, repoName);
      if (checkId !== this.repoNameCheckId) {
        return false;
      }
      if (exists) {
        this.repoNameAvailability = "taken";
        this.repoNameAvailabilityMessage = `Repository ${username}/${repoName} already exists. Choose another name or switch to "Use existing repository".`;
      } else {
        this.repoNameAvailability = "available";
        this.repoNameAvailabilityMessage = `Repository name ${username}/${repoName} is available.`;
      }
      this.updateRepoAvailabilityElement();
      return !exists;
    } catch (error) {
      if (checkId !== this.repoNameCheckId) {
        return false;
      }
      const message = error instanceof Error ? error.message : String(error);
      this.repoNameAvailability = "error";
      this.repoNameAvailabilityMessage = message;
      this.updateRepoAvailabilityElement();
      return false;
    }
  }
  async ensureRepoNameAvailable() {
    if (this.repoMode !== "create") {
      return true;
    }
    if (this.repoNameAvailability === "available") {
      return true;
    }
    const available = await this.checkRepoNameAvailability();
    if (!available && (this.repoNameAvailability === "taken" || this.repoNameAvailability === "error")) {
      new import_obsidian10.Notice(this.repoNameAvailabilityMessage || "Repository name already exists.");
    }
    return available;
  }
  renderRepoAvailability(container) {
    this.repoAvailabilityEl?.remove();
    this.repoAvailabilityEl = childDiv(container, { cls: "github-publish-repo-availability" });
    this.updateRepoAvailabilityElement();
  }
  updateRepoAvailabilityElement() {
    if (!this.repoAvailabilityEl) {
      return;
    }
    this.repoAvailabilityEl.empty();
    if (!this.repoNameAvailabilityMessage) {
      return;
    }
    const isError = this.repoNameAvailability === "taken" || this.repoNameAvailability === "error";
    childEl(this.repoAvailabilityEl, "p", {
      cls: isError ? "github-publish-step-error" : "github-publish-repo-availability-message",
      text: this.repoNameAvailabilityMessage
    });
  }
  render() {
    const { contentEl } = this;
    contentEl.empty();
    contentEl.addClass("github-publish-modal");
    childEl(contentEl, "h2", { text: `GitHub Publish \u2014 Setup (step ${String(this.step)}/4)` });
    switch (this.step) {
      case 1:
        this.renderFolderStep(contentEl);
        break;
      case 2:
        this.renderSiteNameStep(contentEl);
        break;
      case 3:
        this.renderRepoStep(contentEl);
        break;
      case 4:
        this.renderConfirmStep(contentEl);
        break;
    }
    this.renderNav(contentEl);
    if (this.step === 4) {
      const publishBtn = contentEl.querySelector(".github-publish-buttons .mod-cta");
      if (publishBtn instanceof HTMLButtonElement && !publishBtn.disabled) {
        publishBtn.focus();
      }
    }
  }
  applyFolderSuggestions() {
    if (!this.siteNameEdited) {
      this.siteName = suggestSiteNameFromFolder(this.contentFolder, this.app.vault.getName());
    }
    if (!this.repoNameEdited && this.siteName.trim()) {
      this.repoName = suggestRepoNameFromSiteName(this.siteName);
    }
  }
  renderSiteNameStep(container) {
    childEl(container, "p", {
      text: "Choose a name for your published site. This appears in the browser tab and site header."
    });
    const suggested = suggestSiteNameFromFolder(this.contentFolder, this.app.vault.getName());
    const siteNameSetting = new import_obsidian10.Setting(container).setName("Site name");
    if (!this.siteNameEdited && this.siteName === suggested) {
      siteNameSetting.setDesc(`Suggested from folder: ${this.contentFolder || "(vault root)"}`);
    }
    siteNameSetting.addText((text) => {
      text.setValue(this.siteName).onChange((value) => {
        this.siteName = value;
        this.siteNameEdited = true;
        if (!this.repoNameEdited) {
          this.repoName = suggestRepoNameFromSiteName(value);
        }
      });
      text.inputEl.focus();
    });
  }
  renderFolderStep(container) {
    childEl(container, "p", {
      text: "Select the vault folder to publish. Its contents will be copied to content/ in your GitHub repository."
    });
    if (this.contentFolder) {
      childEl(container, "p", {
        cls: "github-publish-selected-folder",
        text: `Selected: ${this.contentFolder || "(vault root)"}`
      });
    }
    const treeHost = childDiv(container, { cls: "github-publish-folder-tree-host" });
    new FolderTree(this.app, treeHost, {
      selectedPath: this.contentFolder,
      expandedPaths: this.expandedFolders,
      onSelect: (path) => {
        this.contentFolder = path;
        this.applyFolderSuggestions();
        this.render();
      },
      onToggleExpand: (path) => {
        if (this.expandedFolders.has(path)) {
          this.expandedFolders.delete(path);
        } else {
          this.expandedFolders.add(path);
        }
        this.render();
      }
    }).render();
  }
  renderRepoStep(container) {
    childEl(container, "p", { text: "Create a new repository or use an existing empty one." });
    new import_obsidian10.Setting(container).setName("Repository").addDropdown((dropdown) => {
      dropdown.addOption("create", "Create new repository").addOption("existing", "Use existing repository").setValue(this.repoMode).onChange((value) => {
        this.repoMode = value;
        this.resetRepoNameAvailability();
        this.render();
      });
    });
    if (this.repoMode === "create") {
      const suggested = suggestRepoNameFromSiteName(this.siteName);
      new import_obsidian10.Setting(container).setName("New repository name").setDesc(
        this.repoNameEdited || this.repoName !== suggested ? "Lowercase letters, numbers, and hyphens. Will be created as public." : `Suggested from site name. Lowercase letters, numbers, and hyphens. Will be created as public.`
      ).addText((text) => {
        text.setValue(this.repoName).onChange((value) => {
          this.repoName = value;
          this.repoNameEdited = true;
          this.repoNameAvailability = "idle";
          this.repoNameAvailabilityMessage = "";
          this.updateRepoAvailabilityElement();
          this.scheduleRepoNameCheck();
        }).setPlaceholder(suggested || "my-notes-site");
      });
      this.renderRepoAvailability(container);
      this.scheduleRepoNameCheck(true);
    } else {
      childEl(container, "p", { text: "Loading repositories\u2026" });
      void this.renderExistingRepos(container);
    }
  }
  async renderExistingRepos(container) {
    const token = this.plugin.settings.accessToken;
    if (!token) return;
    try {
      const repos = await listUserRepos(token);
      new import_obsidian10.Setting(container).setName("Existing repository").addDropdown((dropdown) => {
        dropdown.addOption("", "Select a repository\u2026");
        for (const repo of repos) {
          dropdown.addOption(repo.name, repo.full_name);
        }
        dropdown.setValue(this.repoName).onChange((value) => {
          this.repoName = value;
        });
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      const errorRow = childDiv(container, { cls: "github-publish-error-row" });
      childEl(errorRow, "p", { cls: "github-publish-step-error", text: message });
      addCopyButton(errorRow, message, {
        ariaLabel: "Copy error message",
        successNotice: "Error copied to clipboard"
      });
    }
  }
  renderConfirmStep(container) {
    const fileCount = this.contentFolder ? countFilesInFolder(this.app.vault, this.contentFolder) : 0;
    childEl(container, "p", { text: "Review your publish settings:" });
    const summary = childEl(container, "dl", { cls: "github-publish-summary" });
    this.addSummaryRow(summary, "Vault folder", this.contentFolder || "(vault root)");
    this.addSummaryRow(summary, "Site name", this.siteName);
    this.addSummaryRow(summary, "GitHub account", this.plugin.settings.githubUsername ?? "");
    this.addSummaryRow(
      summary,
      "Repository",
      this.repoMode === "create" ? `Create: ${this.repoName}` : `Existing: ${this.repoName}`
    );
    this.addSummaryRow(summary, "Files to publish", String(fileCount));
    this.addSummaryRow(
      summary,
      "Live URL",
      `https://${this.plugin.settings.githubUsername}.github.io/${this.repoName}/`
    );
  }
  addSummaryRow(dl, label, value) {
    childEl(dl, "dt", { text: label });
    childEl(dl, "dd", { text: value || "\u2014" });
  }
  renderNav(container) {
    const nav = childDiv(container, { cls: "github-publish-buttons" });
    if (this.step > 1) {
      const backBtn = childEl(nav, "button", { text: "Back" });
      backBtn.addEventListener("click", () => {
        this.step = this.step - 1;
        this.render();
      });
    }
    const nextBtn = childEl(nav, "button", {
      text: this.step === 4 ? "Publish" : "Next",
      cls: "mod-cta"
    });
    if (this.step === 4) {
      nextBtn.disabled = this.isPublishing;
    }
    nextBtn.addEventListener("click", () => {
      this.submitWizard();
    });
  }
  advanceStep() {
    if (!this.validateStep()) {
      return;
    }
    if (this.step === 4) {
      void this.publish();
      return;
    }
    if (this.step === 1) {
      this.applyFolderSuggestions();
    } else if (this.step === 2 && !this.repoNameEdited) {
      this.repoName = suggestRepoNameFromSiteName(this.siteName);
    }
    this.step = this.step + 1;
    this.render();
  }
  async advanceFromRepoStep() {
    if (!this.validateStep()) {
      return;
    }
    const available = await this.ensureRepoNameAvailable();
    if (!available) {
      return;
    }
    this.step = 4;
    this.render();
  }
  validateStep() {
    switch (this.step) {
      case 1: {
        const folderPath = this.contentFolder;
        if (folderPath !== "" && !folderPath.trim()) {
          new import_obsidian10.Notice("Enter a vault folder path.");
          return false;
        }
        const folder = folderPath === "" ? this.app.vault.getRoot() : this.app.vault.getAbstractFileByPath(folderPath);
        if (!(folder instanceof import_obsidian10.TFolder)) {
          new import_obsidian10.Notice("Folder not found in vault.");
          return false;
        }
        return true;
      }
      case 2:
        if (!this.siteName.trim()) {
          new import_obsidian10.Notice("Enter a site name.");
          return false;
        }
        return true;
      case 3:
        if (!this.repoName.trim()) {
          new import_obsidian10.Notice("Enter or select a repository name.");
          return false;
        }
        if (this.repoMode === "create" && !CREATE_REPO_NAME_PATTERN.test(this.repoName)) {
          new import_obsidian10.Notice("Repository name must be lowercase alphanumeric with hyphens.");
          return false;
        }
        return true;
      case 4:
        return true;
      default:
        return true;
    }
  }
  publish() {
    const token = this.plugin.settings.accessToken;
    const username = this.plugin.settings.githubUsername;
    if (!token || !username) return;
    this.isPublishing = true;
    const config = {
      siteName: this.siteName.trim(),
      contentFolder: this.contentFolder.trim(),
      repoMode: this.repoMode,
      repoName: this.repoName.trim()
    };
    saveSetupConfig(this.plugin, config);
    this.close();
    startPublish(this.plugin, config);
  }
};

// src/ui/PublishedSiteCard.ts
var import_obsidian13 = require("obsidian");

// src/github/publishStatus.ts
async function checkPublishStatus(token, owner, repo, liveUrl) {
  const [repository, liveSite] = await Promise.all([
    checkRepository(token, owner, repo),
    checkLiveSite(liveUrl)
  ]);
  return { repository, liveSite };
}
async function checkRepository(token, owner, repo) {
  try {
    if (token) {
      await githubRequest(token, "GET", `/repos/${owner}/${repo}`);
      return { status: "live", detail: "Repository reachable" };
    }
    const response = await fetchUrl({
      url: `https://api.github.com/repos/${owner}/${repo}`,
      method: "GET",
      headers: {
        Accept: "application/vnd.github+json",
        "User-Agent": "GitHub-Publish-Obsidian-Plugin"
      },
      throw: false
    });
    if (response.status === 200) {
      return { status: "live", detail: "Repository reachable", httpStatus: response.status };
    }
    if (response.status === 404) {
      return { status: "unreachable", detail: "Repository not found", httpStatus: response.status };
    }
    return {
      status: "error",
      detail: `Unexpected response (${response.status})`,
      httpStatus: response.status
    };
  } catch (error) {
    if (error instanceof GitHubApiError && error.status === 404) {
      return { status: "unreachable", detail: "Repository not found", httpStatus: 404 };
    }
    log("Repository status check failed", error);
    return {
      status: "error",
      detail: error instanceof Error ? error.message : "Repository check failed"
    };
  }
}
async function checkLiveSite(liveUrl) {
  try {
    const response = await fetchUrl({
      url: liveUrl,
      method: "GET",
      throw: false
    });
    if (response.status >= 200 && response.status < 400) {
      return { status: "live", detail: "Site is live", httpStatus: response.status };
    }
    if (response.status === 404) {
      return {
        status: "unreachable",
        detail: "Site not found (Pages may still be deploying)",
        httpStatus: response.status
      };
    }
    return {
      status: "error",
      detail: `HTTP ${response.status}`,
      httpStatus: response.status
    };
  } catch (error) {
    log("Live site status check failed", error);
    return {
      status: "error",
      detail: error instanceof Error ? error.message : "Site check failed"
    };
  }
}

// src/buildFlags.ts
var showAdvancedSettings = false;
var isDevBuild = false;
var buildCommit = "3fd1d29";

// src/ui/UntrackSiteModal.ts
var import_obsidian11 = require("obsidian");
var UntrackSiteModal = class extends import_obsidian11.Modal {
  constructor(app, site, onConfirm) {
    super(app);
    this.site = site;
    this.onConfirm = onConfirm;
  }
  onOpen() {
    const { contentEl } = this;
    contentEl.empty();
    contentEl.addClass("github-publish-modal");
    const repoUrl = getSiteRepoUrl(this.site);
    childEl(contentEl, "h2", { text: "Stop tracking this site?" });
    childEl(contentEl, "p", {
      text: `GitHub Publish will stop tracking "${this.site.siteName}". Your vault notes are not changed.`
    });
    childEl(contentEl, "p", {
      text: "The GitHub repository will still exist. Delete it on GitHub if you no longer need the published site."
    });
    const linkRow = childDiv(contentEl, { cls: "github-publish-untrack-repo-link" });
    childEl(linkRow, "span", { text: "Repository: " });
    const link = childEl(linkRow, "a", {
      href: repoUrl,
      text: siteId(this.site.owner, this.site.repo)
    });
    link.target = "_blank";
    link.rel = "noopener noreferrer";
    const nav = childDiv(contentEl, { cls: "github-publish-buttons" });
    const cancelBtn = childEl(nav, "button", { text: "Cancel" });
    cancelBtn.addEventListener("click", () => {
      this.close();
    });
    const confirmBtn = childEl(nav, "button", {
      text: "Stop tracking",
      cls: "mod-warning"
    });
    confirmBtn.addEventListener("click", () => {
      this.onConfirm();
      this.close();
    });
  }
};

// src/ui/QuartzConfigModal.ts
var import_obsidian12 = require("obsidian");
var QUARTZ_CONFIGURATION_URL = "https://quartz.jzhao.xyz/configuration";
var QuartzConfigModal = class extends import_obsidian12.Modal {
  constructor(app, plugin, site, onChanged) {
    super(app);
    this.plugin = plugin;
    this.site = site;
    this.onChanged = onChanged;
    this.defaultConfig = resolveDefaultQuartzConfig(publishBundleContextFromSite(this.site));
  }
  onOpen() {
    const { contentEl } = this;
    contentEl.empty();
    contentEl.addClass("github-publish-modal");
    childEl(contentEl, "h2", { text: "Edit Quartz configuration" });
    childEl(contentEl, "p", {
      text: `Customize quartz.config.yaml for "${this.site.siteName}". Saved changes are uploaded the next time you publish changes for this site.`
    });
    const docsRow = childDiv(contentEl, { cls: "github-publish-config-docs" });
    const docsLink = childEl(docsRow, "a", {
      cls: "github-publish-config-docs-link",
      href: QUARTZ_CONFIGURATION_URL,
      text: "Learn how to configure Quartz here"
    });
    docsLink.target = "_blank";
    docsLink.rel = "noopener noreferrer";
    const editor = childEl(contentEl, "textarea", {
      cls: "github-publish-config-editor"
    });
    editor.spellcheck = false;
    editor.disabled = true;
    editor.value = "Loading\u2026";
    void readSiteConfigOverride(this.plugin.app, this.site.id).then((override) => {
      editor.value = override ?? this.defaultConfig;
      editor.disabled = false;
    }).catch((error) => {
      editor.value = this.defaultConfig;
      editor.disabled = false;
      new import_obsidian12.Notice(
        `Could not read saved config: ${error instanceof Error ? error.message : String(error)}`
      );
    });
    const nav = childDiv(contentEl, { cls: "github-publish-buttons github-publish-config-nav" });
    const revealBtn = childEl(nav, "button", {
      text: revealInFileManagerLabel(),
      cls: "github-publish-config-reveal"
    });
    revealBtn.addEventListener("click", () => {
      void this.revealInFileManager(editor.value);
    });
    const navActions = childDiv(nav, { cls: "github-publish-config-nav-actions" });
    const cancelBtn = childEl(navActions, "button", { text: "Cancel" });
    cancelBtn.addEventListener("click", () => this.close());
    const resetBtn = childEl(navActions, "button", { text: "Reset to default" });
    resetBtn.addEventListener("click", () => {
      editor.value = this.defaultConfig;
    });
    const saveBtn = childEl(navActions, "button", { text: "Save", cls: "mod-cta" });
    saveBtn.addEventListener("click", () => {
      void this.save(editor.value);
    });
  }
  async revealInFileManager(content) {
    try {
      const absolutePath = await ensureSiteConfigOnDisk(
        this.plugin.app,
        this.site.id,
        content
      );
      openParentFolderInFileManager(absolutePath);
      this.onChanged?.();
      new import_obsidian12.Notice(`${revealInFileManagerLabel()}: quartz.config.yaml`);
    } catch (error) {
      new import_obsidian12.Notice(
        `Could not reveal config file: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }
  async save(content) {
    try {
      if (content.trim() === this.defaultConfig.trim()) {
        await removeSiteConfigOverride(this.plugin.app, this.site.id);
        new import_obsidian12.Notice("Using the default Quartz configuration.");
      } else {
        await writeSiteConfigOverride(this.plugin.app, this.site.id, content);
        new import_obsidian12.Notice("Quartz configuration saved.");
      }
      this.onChanged?.();
      this.close();
    } catch (error) {
      new import_obsidian12.Notice(
        `Could not save config: ${error instanceof Error ? error.message : String(error)}`
      );
    }
  }
};

// src/ui/PublishedSiteCard.ts
var PublishedSiteCard = class {
  constructor(app, plugin, site, isStale, onPublishChanges, onUntrack, onChanged) {
    this.app = app;
    this.plugin = plugin;
    this.site = site;
    this.isStale = isStale;
    this.onPublishChanges = onPublishChanges;
    this.onUntrack = onUntrack;
    this.onChanged = onChanged;
  }
  render(container) {
    const liveUrl = getSiteLiveUrl(this.site);
    const repoUrl = getSiteRepoUrl(this.site);
    const token = this.plugin.settings.accessToken;
    const card = childDiv(container, { cls: "github-publish-site-card" });
    const header = childDiv(card, { cls: "github-publish-site-card-header" });
    childEl(header, "h4", { text: this.site.siteName });
    addTrashButton(header, {
      ariaLabel: `Stop tracking ${this.site.siteName}`,
      onClick: () => {
        new UntrackSiteModal(this.app, this.site, () => {
          this.onUntrack(this.site);
        }).open();
      }
    });
    const summary = childEl(card, "dl", { cls: "github-publish-summary" });
    this.addSummaryRow(summary, "Vault folder", this.site.contentFolder);
    if (showAdvancedSettings) {
      const sha = resolveQuartzCommitSha(this.site.quartzCommitSha);
      this.addSummaryRow(summary, "Quartz version", getQuartzVersionLabel(sha));
    }
    childEl(summary, "dt", { text: "Repository" });
    const repoValue = childEl(summary, "dd", { cls: "github-publish-summary-inline" });
    const repoStatus = childSpan(repoValue, {
      cls: "github-publish-status github-publish-status-checking"
    });
    repoStatus.setText("Checking\u2026");
    const repoLink = childEl(repoValue, "a", {
      cls: "github-publish-summary-link",
      href: repoUrl,
      text: siteId(this.site.owner, this.site.repo)
    });
    repoLink.target = "_blank";
    repoLink.rel = "noopener noreferrer";
    childEl(summary, "dt", { text: "Live site" });
    const liveValue = childEl(summary, "dd", { cls: "github-publish-summary-inline" });
    const liveStatus = childSpan(liveValue, {
      cls: "github-publish-status github-publish-status-checking"
    });
    liveStatus.setText("Checking\u2026");
    const liveLink = childEl(liveValue, "a", {
      cls: "github-publish-summary-link",
      href: liveUrl,
      text: liveUrl
    });
    liveLink.target = "_blank";
    liveLink.rel = "noopener noreferrer";
    childEl(summary, "dt", { text: "Changes" });
    const changesValue = childEl(summary, "dd", { cls: "github-publish-changes-row" });
    const changesStatus = childSpan(changesValue, {
      cls: "github-publish-status github-publish-status-checking"
    });
    const isPublishing = this.plugin.isSitePublishing(this.site.id);
    let publishBtn = null;
    if (isPublishing) {
      changesStatus.setText("Publishing in progress");
    } else {
      changesStatus.setText("Checking for changes\u2026");
      publishBtn = childEl(changesValue, "button", {
        cls: "mod-cta github-publish-changes-button",
        text: "Publish changes"
      });
      publishBtn.disabled = true;
      publishBtn.addEventListener("click", () => {
        if (!token) {
          new import_obsidian13.Notice("Connect to GitHub in settings first.");
          return;
        }
        this.onPublishChanges(this.site);
      });
    }
    if (token) {
      void checkPublishStatus(token, this.site.owner, this.site.repo, liveUrl).then((result) => {
        if (this.isStale()) return;
        this.applyStatusCheck(repoStatus, result.repository);
        this.applyStatusCheck(liveStatus, result.liveSite);
      });
    } else {
      repoStatus.setText("Connect GitHub to check status");
      liveStatus.setText("Connect GitHub to check status");
    }
    const actions = childDiv(card, { cls: "github-publish-site-actions" });
    const configBtn = childEl(actions, "button", {
      cls: "github-publish-config-button",
      text: "Edit Quartz config"
    });
    configBtn.addEventListener("click", () => {
      new QuartzConfigModal(this.app, this.plugin, this.site, () => {
        this.onChanged?.();
      }).open();
    });
    if (isPublishing) {
      return;
    }
    void detectUnpublishedChanges(this.app, this.site).then((result) => {
      if (this.isStale()) return;
      if (!publishBtn) return;
      if (!result) {
        changesStatus.removeClass("github-publish-status-checking");
        changesStatus.addClass("github-publish-status-error");
        changesStatus.setText("Unable to check for changes");
        return;
      }
      const hasChanges = countDiffChanges(result.diff) > 0 || result.configChanged || result.toolchainChanged;
      changesStatus.removeClass(
        "github-publish-status-checking",
        "github-publish-status-live",
        "github-publish-status-unreachable"
      );
      changesStatus.addClass(
        hasChanges ? "github-publish-changes-pending" : "github-publish-status-live"
      );
      changesStatus.setText(result.summary);
      publishBtn.disabled = !hasChanges;
    });
  }
  applyStatusCheck(element, check) {
    element.removeClass(
      "github-publish-status-checking",
      "github-publish-status-live",
      "github-publish-status-unreachable",
      "github-publish-status-error"
    );
    element.addClass(`github-publish-status-${check.status}`);
    const statusLabel = check.status === "live" ? "Live" : check.status === "unreachable" ? "Unreachable" : check.status === "error" ? "Error" : "Checking\u2026";
    element.setText(statusLabel);
  }
  addSummaryRow(dl, label, value) {
    childEl(dl, "dt", { text: label });
    childEl(dl, "dd", { text: value || "\u2014" });
  }
};

// src/ui/SitePickerModal.ts
var import_obsidian14 = require("obsidian");
var SitePickerModal = class extends import_obsidian14.FuzzySuggestModal {
  constructor(app, sites, onChoose) {
    super(app);
    this.sites = sites;
    this.onChoose = onChoose;
  }
  getItems() {
    return this.sites;
  }
  getItemText(site) {
    return `${site.siteName} (${site.owner}/${site.repo})`;
  }
  onChooseItem(site) {
    this.onChoose(site);
  }
};

// src/utils/pluginData.ts
async function loadPluginSettingsData(plugin) {
  const raw = await plugin.loadData();
  if (raw === null || typeof raw !== "object") {
    return {};
  }
  return raw;
}

// main.ts
var GitHubPublishPlugin = class extends import_obsidian15.Plugin {
  constructor() {
    super(...arguments);
    this.settings = DEFAULT_SETTINGS;
    this.publishingSiteIds = /* @__PURE__ */ new Set();
    this.settingTab = null;
  }
  async onload() {
    await this.loadSettings();
    this.settingTab = new GitHubPublishSettingTab(this.app, this);
    this.addSettingTab(this.settingTab);
    this.addCommand({
      id: "setup-site",
      name: "Set up site",
      callback: () => this.openSetupWizard()
    });
    this.addCommand({
      id: "continue-publish",
      name: "Continue publish",
      callback: () => startPublish(this)
    });
    this.addCommand({
      id: "publish-changes",
      name: "Publish changes",
      callback: () => this.openPublishChangesPicker()
    });
    this.addRibbonIcon("globe", "GitHub Publish setup", () => {
      this.openSetupWizard();
    });
  }
  async loadSettings() {
    const stored = await loadPluginSettingsData(this);
    this.settings = migratePluginSettings({ ...DEFAULT_SETTINGS, ...stored });
  }
  async saveSettings() {
    await this.saveData(this.settings);
  }
  async setAccessToken(token) {
    const user = await fetchGitHubUser(token);
    this.settings.accessToken = token;
    this.settings.githubUsername = user.login;
    await this.saveSettings();
    return user;
  }
  markSitePublishing(siteId2) {
    this.publishingSiteIds.add(siteId2);
    this.refreshSettingsTab();
  }
  clearSitePublishing(siteId2) {
    this.publishingSiteIds.delete(siteId2);
    this.refreshSettingsTab();
  }
  isSitePublishing(siteId2) {
    return this.publishingSiteIds.has(siteId2);
  }
  refreshSettingsTab() {
    this.settingTab?.render();
  }
  openSetupWizard() {
    if (!this.settings.accessToken) {
      new import_obsidian15.Notice("Connect to GitHub in plugin settings first.");
      return;
    }
    if (this.settings.savedSetup) {
      this.settings.savedSetup = null;
      void this.saveSettings();
      this.refreshSettingsTab();
    }
    new SetupModal(this.app, this).open();
  }
  openPublishChangesPicker() {
    const sites = getPublishableSites(this);
    if (sites.length === 0) {
      new import_obsidian15.Notice("Complete initial publish before publishing changes.");
      return;
    }
    if (sites.length === 1) {
      const site = sites[0];
      if (site) startPublishChanges(this, site);
      return;
    }
    new SitePickerModal(this.app, sites, (site) => {
      startPublishChanges(this, site);
    }).open();
  }
  async untrackPublishedSite(site) {
    this.settings.publishedSites = removePublishedSite(this.settings.publishedSites, site.id);
    await this.saveSettings();
    this.refreshSettingsTab();
    new import_obsidian15.Notice(`Stopped tracking ${site.siteName}`);
  }
};
var GitHubPublishSettingTab = class extends import_obsidian15.PluginSettingTab {
  constructor(app, plugin) {
    super(app, plugin);
    this.plugin = plugin;
    this.connecting = false;
    this.deviceUserCode = null;
    this.statusCheckId = 0;
  }
  // Obsidian calls `display()` to render the settings tab UI.
  // Keep it for compatibility, but avoid referencing it internally since it's deprecated in newer typings.
  display() {
    this.render();
  }
  render() {
    const { containerEl } = this;
    this.statusCheckId++;
    const checkId = this.statusCheckId;
    const isStale = () => checkId !== this.statusCheckId;
    containerEl.empty();
    const connected = Boolean(this.plugin.settings.accessToken);
    if (!connected) {
      childEl(containerEl, "p", {
        text: "Connect your GitHub account to start publishing your vault or a specific folder. Authorization uses public repo and workflow scopes."
      });
    }
    new import_obsidian15.Setting(containerEl).setName("GitHub account").setDesc(this.plugin.settings.githubUsername ?? "Not connected").addButton((btn) => {
      if (connected) {
        btn.setButtonText("Disconnect");
        btn.onClick(async () => {
          this.plugin.settings.accessToken = null;
          this.plugin.settings.githubUsername = null;
          await this.plugin.saveSettings();
          this.render();
        });
      } else {
        btn.setButtonText(this.connecting ? "Connecting\u2026" : "Connect to GitHub").setCta();
        btn.setDisabled(this.connecting);
        btn.onClick(() => {
          this.connecting = true;
          this.deviceUserCode = null;
          this.render();
          void connectGitHub(this.plugin, {
            onUserCode: (code) => {
              this.deviceUserCode = code;
              this.render();
            }
          }).then((user) => {
            new import_obsidian15.Notice(`Connected as ${user.login}`);
            this.connecting = false;
            this.deviceUserCode = null;
            this.render();
          }).catch((error) => {
            new import_obsidian15.Notice(error instanceof Error ? error.message : String(error));
            this.connecting = false;
            this.deviceUserCode = null;
            this.render();
          });
        });
      }
    });
    if (this.connecting) {
      if (this.deviceUserCode) {
        childEl(containerEl, "p", { text: "Enter this code on GitHub:" });
        const codeRow = childDiv(containerEl, { cls: "github-publish-device-code-row" });
        childEl(codeRow, "div", {
          cls: "github-publish-device-code",
          text: this.deviceUserCode
        });
        addCopyButton(codeRow, this.deviceUserCode, {
          ariaLabel: "Copy device code",
          successNotice: "Device code copied to clipboard"
        });
        childEl(containerEl, "p", { text: "Waiting for authorization\u2026" });
      } else {
        childEl(containerEl, "p", { text: "Requesting device code\u2026" });
      }
    }
    if (showAdvancedSettings) {
      this.renderAdvancedSettings(containerEl);
    }
    if (isDevBuild || showAdvancedSettings) {
      this.renderDevelopmentSettings(containerEl);
    }
    new import_obsidian15.Setting(containerEl).setName("Publish new site").setDesc("Choose a vault folder and GitHub repository to publish.").addButton((btn) => {
      btn.setButtonText("Start Setup");
      if (connected) {
        btn.setCta();
      } else {
        btn.setDisabled(true);
      }
      btn.onClick(() => {
        this.plugin.openSetupWizard();
      });
    });
    const { publishedSites } = this.plugin.settings;
    if (publishedSites.length > 0) {
      new import_obsidian15.Setting(containerEl).setName("Published sites").setHeading();
      const sitesContainer = childDiv(containerEl, { cls: "github-publish-sites-list" });
      for (const site of publishedSites) {
        new PublishedSiteCard(
          this.app,
          this.plugin,
          site,
          isStale,
          (selected) => startPublishChanges(this.plugin, selected),
          (selected) => {
            void this.plugin.untrackPublishedSite(selected);
          },
          () => this.render()
        ).render(sitesContainer);
      }
    } else {
      const saved = this.plugin.settings.savedSetup;
      if (saved) {
        this.renderSavedSetup(containerEl, saved);
      }
    }
    if (isDevBuild) {
      new import_obsidian15.Setting(containerEl).setName("Build").setDesc(
        [`v${this.plugin.manifest.version}`, buildCommit, "dev"].concat(showAdvancedSettings ? ["advanced"] : []).join(" \xB7 ")
      );
    }
  }
  renderAdvancedSettings(containerEl) {
    new import_obsidian15.Setting(containerEl).setName("Advanced").setHeading();
    const activeSha = resolveQuartzCommitSha(this.plugin.settings.quartzCommitSha);
    const isKnownSha = TESTED_QUARTZ_VERSIONS.some((version) => version.sha === activeSha);
    const dropdownValue = isKnownSha ? activeSha : "custom";
    new import_obsidian15.Setting(containerEl).setName("Quartz version").setDesc("Pinned Quartz commit used when publishing a new site.").addDropdown((dropdown) => {
      for (const version of TESTED_QUARTZ_VERSIONS) {
        dropdown.addOption(version.sha, version.label);
      }
      dropdown.addOption("custom", "Custom commit\u2026");
      dropdown.setValue(dropdownValue).onChange(async (value) => {
        if (value === "custom") {
          this.plugin.settings.quartzCommitSha = isKnownSha ? "" : activeSha;
        } else {
          const sha = value;
          this.plugin.settings.quartzCommitSha = sha;
        }
        await this.plugin.saveSettings();
        this.render();
      });
    });
    if (dropdownValue === "custom") {
      new import_obsidian15.Setting(containerEl).setName("Custom Quartz commit SHA").setDesc(`Leave blank to use the plugin default (${DEFAULT_QUARTZ_COMMIT.slice(0, 7)}).`).addText((text) => {
        text.setPlaceholder(DEFAULT_QUARTZ_COMMIT).setValue(this.plugin.settings.quartzCommitSha ?? "").onChange(async (value) => {
          const trimmed = value.trim();
          this.plugin.settings.quartzCommitSha = trimmed || null;
          await this.plugin.saveSettings();
        });
      });
    }
  }
  renderDevelopmentSettings(containerEl) {
    new import_obsidian15.Setting(containerEl).setName("Development").setHeading();
    new import_obsidian15.Setting(containerEl).setName("Preview publish success").setDesc("Open the success screen with mock data for githubpublish-wiki.").addButton(
      (btn) => btn.setButtonText("Preview").onClick(() => {
        ProgressModal.openDonePreview(this.app, {
          mode: "incremental",
          liveUrl: "https://oilandrust.github.io/githubpublish-wiki/"
        });
      })
    );
  }
  renderSavedSetup(containerEl, saved) {
    new import_obsidian15.Setting(containerEl).setName("Saved setup").setHeading();
    const summary = childEl(containerEl, "dl", { cls: "github-publish-summary" });
    this.addSummaryRow(summary, "Site name", saved.siteName);
    this.addSummaryRow(summary, "Vault folder", saved.contentFolder);
    this.addSummaryRow(
      summary,
      "Repository",
      saved.repoMode === "create" ? `Create: ${saved.repoName}` : `Existing: ${saved.repoName}`
    );
    new import_obsidian15.Setting(containerEl).addButton(
      (btn) => btn.setButtonText("Continue publish").setCta().onClick(() => {
        if (!this.plugin.settings.accessToken) {
          new import_obsidian15.Notice("Connect to GitHub in settings first.");
          return;
        }
        startPublish(this.plugin);
      })
    );
  }
  addSummaryRow(dl, label, value) {
    childEl(dl, "dt", { text: label });
    childEl(dl, "dd", { text: value || "\u2014" });
  }
};

/* nosourcemap */