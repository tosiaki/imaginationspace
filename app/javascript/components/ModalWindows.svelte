<script>
  import {modalWindowStore} from '../stores';
  import CreateSeries from './CreateSeries.svelte';
  import AddToSeries from './AddToSeries.svelte';

  const modalWindows = {
    CreateSeries,
    AddToSeries
  };
  const close = modalWindow => modalWindowStore.update(modalWindows => {
    modalWindows.splice(modalWindows.indexOf(modalWindow), 1);
    return modalWindows;
  });
</script>

<style>
  .modal-area {
    position: fixed;
    z-index: 1;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.4);
  }

  .modal-window {
    border-radius: 0.7em;
    background-color: rgb(240, 240, 255);
    margin: 2em auto;
    max-height: 90vh;
    overflow: auto;
    padding: 3em;
    border: 1px solid rgb(110, 110, 110);
    width: 80%;
  }
</style>

{#if $modalWindowStore.length}
  <div class="modal-area">
    {#each $modalWindowStore as { title, componentName }}
      <div class="modal-window">
        <header>
          {#if title}
            <h2>{title}</h2>
          {/if}
          <button class="close" on:click={close}>close</button>
        </header>
        <section class="body">
          <svelte:component this={modalWindows[componentName]} on:done={close} />
        </section>
      </div>
    {/each}
  </div>
{/if}
