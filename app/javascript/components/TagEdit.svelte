<script>
  export let tags = [];
  export let context = '';

  let input = "";
  let showAutocomplete = false;
  let autocompleteItems;

  let inputElement;

  const addTag = (tagToAdd = input) => {
    if (tagToAdd.trim() && !tags.includes(tagToAdd.trim())) {
      tags.push(tagToAdd.trim());
      tags = tags;
      input = '';
      showAutocomplete = false;
    }
  }

  const removeTag = tag => {
    tags.splice(tags.indexOf(tag), 1);
    tags = tags;
  };

  const removeLastTag = () => {
    tags.splice(tags.length-1, 1);
    tags = tags;
  };

  const handleKeydown = ({ key }) => {
    if (key === 'Enter') {
      addTag();
    } else if (key === 'ArrowRight' && input.length === inputElement.selectionEnd) {
      addTag();
    } else if (key === 'Backspace' && !input) {
      removeLastTag();
    }
  };

  const getAutocomplete = async () => {
    if(input.trim()) {
      const url = new URL('/article_tags', document.location);
      url.search = new URLSearchParams({
        value: input.trim(),
        context 
      });
      autocompleteItems = (await (await fetch(url, {
        headers: { 'Content-Type': 'application/json' }
      })).json()).filter(item => !tags.includes(item));
      showAutocomplete = true;
    }
  };

  $: input && getAutocomplete();
</script>

<style lang="scss">
  .tag-input-area {
    border: 1px solid rgba(240, 240, 255, 0.9);
    background-color: rgba(190, 190, 255, 0.8);
    padding: 0.3em;
    border-radius: 0.3em;
  }

  .tag-input-list {
    display: inline;
  }

  .tag-input-item {
    display: inline-block;
    border: 1px solid rgba(200, 200, 255, 0.8);
    border-radius: 0.2em;
    background-color: rgba(220, 220, 255, 0.8);
    padding: 0.2em;
    margin: 0;

    &:not(:first-child) {
      margin-left: 0.4em;
    }
  }

  .tag-input-element{ 
    width: auto;
    background-color: transparent;
    box-shadow: none;
    border: 1px dotted rgba(255, 230, 230, 0.6);

    &:focus {
      outline: 1px solid rgba(255, 210, 250, 0.9);
    }
  }

  .tag-input-autocomplete {
    background-color: rgba(230, 200, 245, 0.9);
    border: 1px solid rgba(240, 190, 245, 0.9);
    border-radius: 0.3em;
    padding: 0.3em;

    &-item {
      margin: 0;

      &:hover {
        background-color: rgba(250, 240, 255, 0.9);
      }
    }
  }
</style>

<div class="tag-input">
  <div class="tag-input-area" on:click={() => inputElement.focus()}>
    <ul class="tag-input-list">
      {#each tags as tag}
        <li class="tag-input-item">{tag} <span on:click={removeTag(tag)}>(x)</span></li>
      {/each}
    </ul>
    <input class="tag-input-element" bind:value={input} on:blur={() => addTag()} on:keydown={handleKeydown} bind:this={inputElement} />
  </div>
  {#if showAutocomplete}
    <ul class="tag-input-autocomplete">
      {#each autocompleteItems as autocompleteItem}
        <li class="tag-input-autocomplete-item" on:mousedown|preventDefault={addTag(autocompleteItem)}>{autocompleteItem}</li>
      {/each}
    </ul>
  {/if}
</div>
