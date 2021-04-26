import CreateSeriesButton from '../components/CreateSeriesButton.svelte';
import AddToSeriesButton from '../components/AddToSeriesButton.svelte';
import ModalWindows from '../components/ModalWindows.svelte';
import FlashMessages from '../components/FlashMessages.svelte';
import DisplayContent from '../components/DisplayContent.svelte';
import DisplayImage from '../components/DisplayImage.svelte';
import { displayContentStore, displayImageStore } from '../stores';

const tagsOfCategory = (element, category) => 
  Array.prototype.map.call(
    element.querySelectorAll(`.tag[data-category='${category}']`),
    tagElement => tagElement.innerText
  );

document.addEventListener('turbolinks:load', event => {
  displayContentStore.set({});
  const createSeriesButton = document.getElementById('create-series-button');
  createSeriesButton && (createSeriesButton.innerHTML = '');
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
    target: displayContent,
    props: {
      tagEditor: JSON.parse(document.body.dataset.tagEditor)
    }
  });

  for (let statusArea of document.getElementsByClassName('status-content')) {
    statusArea.addEventListener('click', event => {
      event.preventDefault();
      displayContentStore.set({
        article: statusArea.dataset.articleId,
        title: statusArea.getElementsByTagName('h3')[0].getElementsByTagName('a')[0].innerText,
        pages: statusArea.dataset.pages,
        tags: Object.assign({}, ...[
          'derivative',
          'relationship',
          'character',
          'other',
          'language',
          'author'
        ].map(category => ({
          [category]: tagsOfCategory(statusArea, category)
        })))
      });
    });
  }

  const displayImage = document.getElementById('display-image');
  displayImage.innerHTML = '';
  new DisplayImage({
    target: displayImage
  });

  for (let messageImage of document.getElementsByClassName('message-image')) {
    messageImage.addEventListener('click', event => {
      event.preventDefault();
      displayImageStore.set({
        image: messageImage.getAttribute('src')
      });
    });
  }
});
