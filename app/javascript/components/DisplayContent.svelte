<script>
  import { displayContentStore } from '../stores';

  let currentPage = 1;
  let userActive = false;
  let displayMode = 'single';

  let setUserInactive;

  let contentArea;

  const displayModeLabels = {
    single: 'Single',
    double: 'Double'
  };

  $: contentPromise = (async () => 
    $displayContentStore.article && await (await fetch(`/articles/${$displayContentStore.article}`, {
      headers: { 'Content-Type': 'application/json' }
    })).json())();

  $: $displayContentStore && (currentPage = 1);

  const goBack = () => {
    if (displayMode === 'single') {
      if (currentPage > 1) {
        currentPage--;
      } else {
        setUserActive();
      }
    } else {
      if (currentPage > 1) {
        currentPage = Math.max(1, currentPage-2);
      } else {
        setUserActive();
      }
    }
  };
  const goForward = () => {
    if (displayMode === 'single') {
      if (currentPage < $displayContentStore.pages) {
        currentPage++;
      } else {
        setUserActive();
      }
    } else {
      if (currentPage  + 1 < $displayContentStore.pages) {
        currentPage = Math.min($displayContentStore.pages - 1, currentPage+2);
      } else {
        setUserActive();
      }
    }
  };
  const close = () => $displayContentStore = {};
  const setUserActive = () => {
    userActive = true;
    clearTimeout(setUserInactive);
    setUserInactive = setTimeout(() => {
      userActive = false;
    }, 2000);
  };
  const handleKeydown = ({ key }) => {
    if (key === 'ArrowLeft' && currentPage > 1) {
      goBack();
    } else if (key === 'ArrowRight' && currentPage < $displayContentStore.pages) {
      goForward();
    } else if (key === 'Escape') {
      close();
    }
  };
  const handleClick = ({ offsetX }) => {
    if (offsetX > contentArea.offsetWidth/2) {
      goForward();
    } else {
      goBack();
    }
  };
  const toggleDisplay = () => {
    if (displayMode === 'single') {
      displayMode = 'double';
    } else {
      displayMode = 'single';
    }
  }

  const showNextPage = (currentPage, displayMode) => {
    if (displayMode === 'single') {
      if (currentPage < $displayContentStore.pages) {
        return true;
      } else {
        return false;
      }
    } else {
      if (currentPage + 1 < $displayContentStore.pages) {
        return true;
      } else {
        return false;
      }
    }
  }
</script>

<style lang="scss">
  .top-options {
    top: 0;
    left: 0;
    position: fixed;
    width: 100%;
    z-index: 3;
    background-color: rgba(255, 255, 255, 0.8);
    padding: 0 1em;
  }

  .bottom-options {
    bottom: 0;
    left: 0;
    position: fixed;
    width: 100%;
    z-index: 3;
    background-color: rgba(255, 255, 255, 0.8);
    padding: 0 1em;
  }

  .toggle-display {
    cursor: pointer;
  }

  .options-list {
    display: flex;
    justify-content: space-between;
  }

  .display-content-area {
    position: fixed;
    top: 0;
    left: 0;
    z-index: 2;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.4);
    cursor: pointer;
  }

  .display-content-area-container {
    display: flex;
    justify-content: center;

    :global(img) {
      max-height: 100vh;
    }
  }

  .display-content-area-box {
    background-color: rgba(255, 255, 255, 0.7);
    pointer-events: none;
    display: flex;
  }

  .tags-area {
    display: inline-block;
    margin-left: 0.4em;
  }

  .tag-list {
    display: inline;

    .tag-list-item {
      display: inline-block;
      margin: 0;

      :not(first-child) {
        margin-left: 0.4em;
      }
    }
  }
</style>

<svelte:window on:mousemove={setUserActive} on:keydown={handleKeydown} />

{#if $displayContentStore.article}
  {#if userActive}
    <div class="top-options">
      <ul class="options-list">
        <li>{#if $displayContentStore.tags.length}<div class="tags-area">Tags: <ul class="tag-list">{#each $displayContentStore.tags as tag}<li class="tag-list-item"><a href="/articles?tags={tag}" class="tag">{tag}</a></li>{/each}</ul></div>{/if}</li>
        <li><a href="/threads/{$displayContentStore.article}">{$displayContentStore.title}</a></li>
        <li><a href="/close" on:click|preventDefault={close}>Close</a></li>
      </ul>
    </div>
    <div class="bottom-options">
      <ul class="options-list">
        <li></li>
        <li>{#if currentPage > 1}<a href="/back" on:click|preventDefault={goBack}>←</a> {/if}Page {currentPage} of {$displayContentStore.pages}{#if showNextPage(currentPage, displayMode)} <a href="/forward" on:click|preventDefault={goForward}>→</a>{/if}</li>
        <li class="toggle-display" on:click={toggleDisplay}>Display: {displayModeLabels[displayMode]}</li>
      </ul>
    </div>
  {/if}

  <div class="display-content-area" on:click={handleClick} bind:this={contentArea}>
    {#await contentPromise}
      <div>Waiting for content data...</div>
    {:then contentData}
      <div class="display-content-area-container">
        <div class="display-content-area-box">
          <div class="display-content-area-page">
            {@html contentData.find(page => page.page_number === currentPage).content}
          </div>
          {#if displayMode === 'double' && currentPage + 1 <= $displayContentStore.pages}
            <div class="display-content-area-page">
              {@html contentData.find(page => page.page_number === currentPage + 1).content}
            </div>
          {/if}
        </div>
      </div>
    {:catch error}
      <div>Cannot find content, error: {error}</div>
    {/await}
  </div>
{/if}
