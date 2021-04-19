<script>
  import { displayContentStore } from '../stores';

  let currentPage = 1;
  let userActive = false;
  let setUserInactive;

  let contentArea;

  $: contentPromise = (async () => 
    $displayContentStore.article && await (await fetch(`/articles/${$displayContentStore.article}`, {
      headers: { 'Content-Type': 'application/json' }
    })).json())();

  $: $displayContentStore && (currentPage = 1);

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
      currentPage--;
    } else if (key === 'ArrowRight' && currentPage < $displayContentStore.pages) {
      currentPage++;
    } else if (key === 'Escape') {
      close();
    }
  };
  const handleClick = ({ offsetX }) => {
    if (offsetX > contentArea.offsetWidth/2) {
      if (currentPage < $displayContentStore.pages) {
        currentPage++;
      } else {
        setUserActive();
      }
    } else {
      if (currentPage > 1) {
        currentPage--;
      } else {
        setUserActive();
      }
    }
  };
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

  .top-options-list {
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
  }
</style>

<svelte:window on:mousemove={setUserActive} on:keydown={handleKeydown} />

{#if $displayContentStore.article}
  {#if userActive}
    <div class="top-options">
      <ul class="top-options-list">
        <li><a href="/threads/{$displayContentStore.article}">Link</a></li>
        <li>{#if currentPage > 1}<a href="/back" on:click|preventDefault={() => currentPage--}>←</a> {/if}Page {currentPage} of {$displayContentStore.pages}{#if currentPage < $displayContentStore.pages} <a href="/forward" on:click|preventDefault={() => currentPage++}>→</a>{/if}</li>
        <li><a href="/close" on:click|preventDefault={close}>Close</a></li>
      </ul>
    </div>
  {/if}

  <div class="display-content-area" on:click={handleClick} bind:this={contentArea}>
    {#await contentPromise}
      <div>Waiting for content data...</div>
    {:then contentData}
      <div class="display-content-area-container">
        <div class="display-content-area-box">
          {@html contentData.find(page => page.page_number === currentPage).content}
        </div>
      </div>
    {:catch error}
      <div>Cannot find content, error: {error}</div>
    {/await}
  </div>
{/if}
