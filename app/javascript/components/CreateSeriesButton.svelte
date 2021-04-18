<script>
  import {modalWindowStore} from '../stores';
  const openCreateSeriesWindow = () => {
    modalWindowStore.update(modalWindows => {
      modalWindows.push(
      { title: 'Create series', componentName: 'CreateSeries' }
    );
      return modalWindows;
    })
  }
</script>

<a href="#" on:click|preventDefault={openCreateSeriesWindow}>Create Series</a>
