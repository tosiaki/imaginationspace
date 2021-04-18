import CreateSeriesButton from '../components/CreateSeriesButton.svelte';
import AddToSeriesButton from '../components/AddToSeriesButton.svelte';
import ModalWindows from '../components/ModalWindows.svelte'
import FlashMessages from '../components/FlashMessages.svelte'

document.addEventListener('turbolinks:load', event => {
  if(!document.body.dataset.svelteLoaded) {
    new CreateSeriesButton({
      target: document.getElementById('create-series-button')
    });

    for (let addToSeriesButton of document.getElementsByClassName('add-to-series')) {
      new AddToSeriesButton({
        target: addToSeriesButton,
        props: {
          articleId: addToSeriesButton.dataset.articleId
        }
      });
    }

    new ModalWindows({
      target: document.getElementById('modal-windows')
    });

    new FlashMessages({
      target: document.getElementById('flash-messages')
    });

    document.body.dataset.svelteLoaded = true;
  }
});
