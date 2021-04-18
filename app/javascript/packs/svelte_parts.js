import CreateSeriesButton from '../components/CreateSeriesButton.svelte';
import ModalWindows from '../components/ModalWindows.svelte'

document.addEventListener('turbolinks:load', () => {
  new CreateSeriesButton({
    target: document.getElementById('create-series-button')
  });

  new ModalWindows({
    target: document.getElementById('modal-windows')
  });
});
