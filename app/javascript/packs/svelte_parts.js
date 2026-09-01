import CreateSeriesButton from '../components/CreateSeriesButton.svelte';
import AddToSeriesButton from '../components/AddToSeriesButton.svelte';
import ModalWindows from '../components/ModalWindows.svelte';
import FlashMessages from '../components/FlashMessages.svelte';
import DisplayContent from '../components/DisplayContent.svelte';
import DisplayImage from '../components/DisplayImage.svelte';
import { displayContentStore, displayImageStore } from '../stores';
import { mount, unmount } from 'svelte';

let mountedComponents = [];

const mountComponent = (component, target, props = {}) => {
  if (!target) return;

  target.replaceChildren();
  const instance = mount(component, { target, props });
  mountedComponents.push(instance);
};

const tagsOfCategory = (element, category) => 
  Array.prototype.map.call(
    element.querySelectorAll(`.tag[data-category='${category}']`),
    tagElement => tagElement.innerText
  );

document.addEventListener('turbolinks:load', event => {
  mountedComponents.forEach(component => unmount(component));
  mountedComponents = [];
  displayContentStore.set({});
  const createSeriesButton = document.getElementById('create-series-button');
  mountComponent(CreateSeriesButton, createSeriesButton);

  for (let addToSeriesButton of document.getElementsByClassName('add-to-series')) {
    mountComponent(AddToSeriesButton, addToSeriesButton, {
      articleId: addToSeriesButton.dataset.articleId
    });
  }

  const modalWindows = document.getElementById('modal-windows');
  mountComponent(ModalWindows, modalWindows);

  const flashMessages = document.getElementById('flash-messages');
  mountComponent(FlashMessages, flashMessages);

  const displayContent = document.getElementById('display-content');
  mountComponent(DisplayContent, displayContent, {
    tagEditor: JSON.parse(document.body.dataset.tagEditor)
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
  mountComponent(DisplayImage, displayImage);

  for (let messageImage of document.getElementsByClassName('message-image')) {
    messageImage.addEventListener('click', event => {
      event.preventDefault();
      displayImageStore.set({
        image: messageImage.getAttribute('src'),
        alt: messageImage.getAttribute('alt') || ''
      });
    });
  }
});
