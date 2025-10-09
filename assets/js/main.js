function setLanguage(language) {
  document.documentElement.setAttribute('lang', language);
  localStorage.setItem('opstream-language', language);

  document.querySelectorAll('[data-language]').forEach((button) => {
    button.classList.toggle('active', button.dataset.language === language);
  });

  document.querySelectorAll('[data-i18n]').forEach((element) => {
    try {
      const translations = JSON.parse(element.dataset.i18n);
      const text = translations[language];
      if (text !== undefined) {
        element.innerHTML = text;
      }
    } catch (error) {
      console.warn('Traduction invalide pour', element, error);
    }
  });

  document.querySelectorAll('[data-i18n-placeholder]').forEach((element) => {
    try {
      const translations = JSON.parse(element.dataset.i18nPlaceholder);
      const text = translations[language];
      if (text !== undefined) {
        element.placeholder = text;
      }
    } catch (error) {
      console.warn('Traduction de placeholder invalide pour', element, error);
    }
  });

  document.querySelectorAll('[data-i18n-value]').forEach((element) => {
    try {
      const translations = JSON.parse(element.dataset.i18nValue);
      const text = translations[language];
      if (text !== undefined) {
        element.value = text;
      }
    } catch (error) {
      console.warn('Traduction de valeur invalide pour', element, error);
    }
  });
}

function restoreLanguage() {
  const savedLanguage = localStorage.getItem('opstream-language') || 'fr';
  setLanguage(savedLanguage);
}

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-language]').forEach((button) => {
    button.addEventListener('click', () => setLanguage(button.dataset.language));
  });

  restoreLanguage();
});
