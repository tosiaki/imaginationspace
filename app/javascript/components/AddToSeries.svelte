<script context="module">
  let seriesList;
  
  export const loadSeriesList = async () => seriesList = await (await fetch('/series', {
    headers: { 'Content-Type': 'application/json' },
  })).json();
  loadSeriesList();
</script>

<script>
  import {createEventDispatcher} from 'svelte';
  import {flashMessageStore} from '../stores';
  import {currentArticleStore} from '../stores';

  const dispatch = createEventDispatcher();

  let series = [];
  const addToSeries = async () => {
    await fetch(`/series/add`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        series,
        articleId: $currentArticleStore
      })
    });
    flashMessageStore.update(flashMessages => {
      flashMessages.addFlashMessage('Added to series', 5000);
      return flashMessages;
    });
    dispatch('done');
  }
</script>

<style>
  .series-list {
    max-height: 65vh;
    overflow: auto;
  }
</style>

<div>
  <form on:submit|preventDefault={addToSeries}>
    <ul class="series-list">
      {#each seriesList as { title, url }}
        <li>
          <label>
            <input type="checkbox" value={url} bind:group={series} />
            {title}
          </label>
        </li>
      {/each}
    </ul>
    <input class="submit" type="submit" value="Add to series" />
  </form>
</div>
