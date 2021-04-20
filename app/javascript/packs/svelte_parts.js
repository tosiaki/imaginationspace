import CreateSeriesButton from '../components/CreateSeriesButton.svelte';
import AddToSeriesButton from '../components/AddToSeriesButton.svelte';
import ModalWindows from '../components/ModalWindows.svelte';
import FlashMessages from '../components/FlashMessages.svelte';
import DisplayContent from '../components/DisplayContent.svelte';
import { displayContentStore } from '../stores';

document.addEventListener('turbolinks:load', event => {
  const createSeriesButton = document.getElementById('create-series-button');
  createSeriesButton.innerHTML = '';
  new CreateSeriesButton({
    target: createSeriesButton
  });

  for (let addToSeriesButton of document.getElementsByClassName('add-to-series')) {
    addToSeriesButton.innerHTML = '';
    new AddToSeriesButton({
      target: addToSeriesButton,
      props: {
        articleId: addToSeriesButton.dataset.articleId
      }
    });
  }

  const modalWindows = document.getElementById('modal-windows');
  modalWindows.innerHTML = '';
  new ModalWindows({
    target: modalWindows
  });

  const flashMessages = document.getElementById('flash-messages');
  flashMessages.innerHTML = '';
  new FlashMessages({
    target: flashMessages
  });

  const displayContent = document.getElementById('display-content');
  displayContent.innerHTML = '';
  new DisplayContent({
    target: displayContent
  });

  for (let statusArea of document.getElementsByClassName('status-content')) {
    statusArea.addEventListener('click', event => {
      event.preventDefault();
      displayContentStore.set({
        article: statusArea.dataset.articleId,
        pages: statusArea.dataset.pages
      });
    });
  }
});
