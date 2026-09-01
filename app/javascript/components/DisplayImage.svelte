<script>
  import { displayImageStore } from '../stores';

  let fit = true;
  let imageElement;

  const toggleDisplay = () => {
    fit = !fit;
  };
  const close = () => $displayImageStore = {};

  const handleClick = event => {
    if (imageElement.contains(event.target)) {
      toggleDisplay();
    } else {
      close();
    }
  };

  const handleKeydown = ({ key }) => {
    if (key === 'Escape') {
      close();
    } else if (key === 'Enter' || key === ' ') {
      toggleDisplay();
    }
  };
</script>

<style lang="scss">
  .display-image-area {
    position: fixed;
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: center;
    background-color: rgba(0, 0, 0, 0.4);
    z-index: 2;
    overflow: auto;
  }

  .display-image-container {
    display: flex;
    align-items: center;
    justify-content: center;

    img {
      cursor: pointer;
    }

    .fit {
      max-height: 100%;
    }
  }
</style>

<svelte:window on:keydown={handleKeydown} />

{#if $displayImageStore.image}
  <div
    class="display-image-area"
    role="button"
    tabindex="0"
    aria-label="Toggle image fit; press Escape to close"
    on:click={handleClick}
    on:keydown|stopPropagation={handleKeydown}
  >
    <div class="display-image-container">
      <img src={$displayImageStore.image} alt={$displayImageStore.alt} bind:this={imageElement} class:fit />
    </div>
  </div>
{/if}
