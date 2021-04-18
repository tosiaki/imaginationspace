<script>
  let name;
  const createSeries = () => console.log(name);
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
    <input class="input" bind:value={name} placeholder="Series title" />
    <input class="submit" type="submit" value="Create" />
  </form>
</div>
