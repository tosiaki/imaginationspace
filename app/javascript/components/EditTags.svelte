<script>
  import {createEventDispatcher} from 'svelte';
  import {tagEditStore, flashMessageStore} from '../stores';
  import TagEdit from './TagEdit.svelte';

  const dispatch = createEventDispatcher();

  const save = async () => {
    const response = await fetch(
      `/articles/${$tagEditStore.articleId}/tags`,
      {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify($tagEditStore.tags)
      }
    );
    if(response.ok) {
      flashMessageStore.update(flashMessages => {
        flashMessages.addFlashMessage('Updated tags', 5000);
        return flashMessages;
      });
      dispatch('done');
    } else {
      flashMessageStore.update(flashMessages => {
        flashMessages.addFlashMessage('Error updating tags', 5000);
        return flashMessages;
      });
    }
  }
</script>

<style>
  .submit {
    background-color: rgba(255, 255, 255, 0.8);
    box-shadow: none;
    margin-top: 0.4em;
    padding: 0.2em;
    border-radius: 0.4em;
    color: rgba(60, 170, 175, 0.8);
  }
</style>

<div>
  <form on:submit|preventDefault={save}>
    <h3>Derivative</h3>
    <TagEdit bind:tags={$tagEditStore.tags.derivative} context="fandom" />
    <h3>Relationship</h3>
    <TagEdit bind:tags={$tagEditStore.tags.relationship} context="relationship" />
    <h3>Character</h3>
    <TagEdit bind:tags={$tagEditStore.tags.character} context="character" />
    <h3>Other</h3>
    <TagEdit bind:tags={$tagEditStore.tags.other} context="other" />
    <h3>Language</h3>
    <TagEdit bind:tags={$tagEditStore.tags.language} context="language" />
    <h3>Author</h3>
    <TagEdit bind:tags={$tagEditStore.tags.author} context="attribution" />
    <input class="submit" type="submit" value="Update" />
  </form>
</div>
