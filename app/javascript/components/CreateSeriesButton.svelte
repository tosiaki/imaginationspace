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

<a href="/createSeries" on:click|preventDefault={openCreateSeriesWindow}>Create series</a>
