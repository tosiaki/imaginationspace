(() => {
  "use strict";

  const STORAGE_KEY = "windyfall.level13.study.v1";
  const FORMAT = 1;
  const startedAt = new Date().toISOString();
  const startedPerformance = performance.now();
  let gameGlobals = null;
  let globalSignals = null;
  let snapshotTimer = null;

  const load = () => {
    try {
      const parsed = JSON.parse(localStorage.getItem(STORAGE_KEY));
      if (parsed && parsed.format === FORMAT && Array.isArray(parsed.events)) return parsed;
    } catch (_error) {
      // Preserve play even if an earlier study record was malformed.
    }
    return { format: FORMAT, sessions: [], events: [] };
  };

  const study = load();
  const session = {
    id: `${Date.now()}-${crypto.getRandomValues(new Uint32Array(1))[0].toString(16)}`,
    startedAt,
    url: location.href,
    userAgent: navigator.userAgent,
  };
  study.sessions.push(session);

  const compact = (value, depth = 0) => {
    if (value == null || typeof value === "string" || typeof value === "number" || typeof value === "boolean") return value;
    if (depth >= 2) return String(value);
    if (Array.isArray(value)) return value.slice(0, 20).map(item => compact(item, depth + 1));
    if (typeof value === "object") {
      const result = {};
      Object.keys(value).slice(0, 30).forEach(key => {
        if (typeof value[key] !== "function") result[key] = compact(value[key], depth + 1);
      });
      return result;
    }
    return String(value);
  };

  const persist = () => localStorage.setItem(STORAGE_KEY, JSON.stringify(study));

  const record = (type, details = {}) => {
    study.events.push({
      sessionId: session.id,
      at: new Date().toISOString(),
      elapsedMs: Math.round(performance.now() - startedPerformance),
      type,
      details: compact(details),
    });
    persist();
  };

  const getSaveInventory = () => Object.keys(localStorage).sort().map(key => ({
    key,
    bytes: (localStorage.getItem(key) || "").length,
  }));

  const snapshot = (reason = "manual") => {
    const state = gameGlobals && gameGlobals.gameState;
    record("snapshot", {
      reason,
      state: state ? {
        level: state.level,
        worldSeed: state.worldSeed,
        gameTime: state.gameTime,
        playTime: state.playTime,
        numCamps: state.numCamps,
        numVisitedSectors: state.numVisitedSectors,
        numUnlockedMilestones: state.numUnlockedMilestones,
        isFinished: state.isFinished,
        unlockedFeatures: state.unlockedFeatures,
        usedFeatures: state.usedFeatures,
        storyStatus: state.storyStatus,
        storyFlags: state.storyFlags,
        foundTradingPartners: state.foundTradingPartners,
        foundLuxuryResources: state.foundLuxuryResources,
        stats: state.stats,
      } : null,
      localStorage: getSaveInventory(),
      visibility: document.visibilityState,
    });
  };

  const signalNames = [
    "gameShownSignal", "gameStateLoadedSignal", "gameStartedSignal",
    "actionButtonClickedSignal", "actionStartedSignal", "actionCompletedSignal",
    "playerPositionChangedSignal", "playerEnteredLevelSignal",
    "playerEnteredCampSignal", "playerLeftCampSignal", "sectorScoutedSignal",
    "campBuiltSignal", "improvementBuiltSignal", "movementBlockerClearedSignal",
    "upgradeUnlockedSignal", "milestoneUnlockedSignal", "featureUnlockedSignal",
    "storyFlagChangedSignal", "dialogueCompletedSignal", "fightEndedSignal",
    "caravanSentSignal", "caravanReturnedSignal", "campEventStartedSignal",
    "campEventEndedSignal", "gameEndedSignal", "errorLoggedSignal",
  ];

  const attach = () => {
    window.require(["game/GlobalSignals", "game/GameGlobals"], (signals, globals) => {
      globalSignals = signals;
      gameGlobals = globals;
      signalNames.forEach(name => {
        const signal = globalSignals[name];
        if (!signal || typeof signal.add !== "function") return;
        signal.add((...args) => {
          record(`signal:${name.replace(/Signal$/, "")}`, { args });
          if (/Unlocked|campBuilt|gameStarted|gameEnded/.test(name)) snapshot(name);
        });
      });
      snapshot("observer-attached");
      snapshotTimer = window.setInterval(() => snapshot("interval"), 60_000);
      record("observer-ready", { signals: signalNames });
      console.info("WindyFall Level 13 study observer ready. Use WindyFallLevel13Study.download() to export data.");
    });
  };

  document.addEventListener("click", event => {
    const target = event.target.closest("button, [action], [data-tab]");
    if (!target) return;
    record("ui-click", {
      element: target.tagName,
      id: target.id || null,
      action: target.getAttribute("action"),
      tab: target.dataset.tab || null,
      text: (target.textContent || "").trim().replace(/\s+/g, " ").slice(0, 160),
    });
  }, true);

  document.addEventListener("visibilitychange", () => {
    record("visibility", { state: document.visibilityState });
    snapshot("visibility-change");
  });
  window.addEventListener("beforeunload", () => snapshot("before-unload"));

  const download = () => {
    snapshot("export");
    const blob = new Blob([JSON.stringify(study, null, 2)], { type: "application/json" });
    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = `level13-study-${new Date().toISOString().replace(/[:.]/g, "-")}.json`;
    link.click();
    setTimeout(() => URL.revokeObjectURL(link.href), 1_000);
  };

  const clear = () => {
    if (snapshotTimer) clearInterval(snapshotTimer);
    localStorage.removeItem(STORAGE_KEY);
    location.reload();
  };

  window.WindyFallLevel13Study = { data: study, snapshot, download, clear };
  record("observer-loaded");

  const waitForRequire = () => {
    if (typeof window.require === "function") attach();
    else setTimeout(waitForRequire, 100);
  };
  waitForRequire();
})();
