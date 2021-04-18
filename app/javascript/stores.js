import {writable} from 'svelte/store';

export const modalWindowStore = writable([]);

const flashMessages = [];
export const flashMessageStore = writable(flashMessages, set => {
  flashMessages.addFlashMessage = (message, time) => {
    const flashMessage = { message };
    flashMessages.push(flashMessage);
    setTimeout(() => {
      flashMessages.splice(flashMessages.indexOf(flashMessage), 1);
      set(flashMessages);
    }, time);
  };
});

export const currentArticleStore = writable('');
