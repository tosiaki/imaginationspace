<script>
  import {createEventDispatcher} from 'svelte';
  import {flashMessageStore} from '../stores';
  import {loadSeriesList} from './AddToSeries.svelte';

  const dispatch = createEventDispatcher();

  let title;
  const createSeries = async () => {
    const response = await fetch('/series', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title })
    });
    if(response.ok) {
      flashMessageStore.update(flashMessages => {
        flashMessages.addFlashMessage('Series created', 5000);
        return flashMessages;
      });
      await loadSeriesList();
    } else {
      flashMessageStore.update(flashMessages => {
        flashMessages.addFlashMessage('Error creating series', 5000);
        return flashMessages;
      });
    }
    dispatch('done');
  }
</script>

<style>
  .input {
    max-width: 800px;
    margin-top: 0.2em;
  }

  .submit {
    margin-top: 0.2em;
  }
</style>

<div>
  <form on:submit|preventDefault={createSeries}>
    <h4>Title</h4>
    <input class="input" bind:value={title} placeholder="Series title" />
    <input class="submit" type="submit" value="Create" />
  </form>
</div>
