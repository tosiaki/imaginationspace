<script>
  export let articleId;

  import {currentArticleStore} from '../stores';

  import {modalWindowStore} from '../stores';
  const openAddToSeriesWindow = () => {
    $currentArticleStore = articleId;
    modalWindowStore.update(modalWindows => {
      modalWindows.push(
        { title: 'Add to series', componentName: 'AddToSeries' }
      );
      return modalWindows;
    });
  }
</script>

<a href="/addToSeries" on:click|preventDefault={openAddToSeriesWindow}>Add to series</a>
