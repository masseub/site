function setLanguage(language) {
  document.documentElement.setAttribute('lang', language);
  localStorage.setItem('opstream-language', language);

  // Toggle active state on language buttons
  document.querySelectorAll('[data-language]').forEach((button) => {
    button.classList.toggle('active', button.dataset.language === language);
  });

  // Translate innerHTML text nodes
  document.querySelectorAll('[data-i18n]').forEach((element) => {
    try {
      const translations = JSON.parse(element.dataset.i18n);
      const text = translations[language];
      if (text !== undefined) {
        element.innerHTML = text;
      }
    } catch (error) {
      console.warn('Traduction invalide (data-i18n) pour', element, error);
    }
  });

  // Translate placeholder attribute
  document.querySelectorAll('[data-i18n-placeholder]').forEach((element) => {
    try {
      const translations = JSON.parse(element.dataset.i18nPlaceholder);
      const text = translations[language];
      if (text !== undefined) {
        element.placeholder = text;
      }
    } catch (error) {
      console.warn('Traduction invalide (placeholder) pour', element, error);
    }
  });

  // Translate value attribute
  document.querySelectorAll('[data-i18n-value]').forEach((element) => {
    try {
      const translations = JSON.parse(element.dataset.i18nValue);
      const text = translations[language];
      if (text !== undefined) {
        element.value = text;
      }
    } catch (error) {
      console.warn('Traduction invalide (value) pour', element, error);
    }
  });

  // Translate alt attribute
  document.querySelectorAll('[data-i18n-alt]').forEach((element) => {
    try {
      const translations = JSON.parse(element.dataset.i18nAlt);
      const text = translations[language];
      if (text !== undefined) {
        element.alt = text;
      }
    } catch (error) {
      console.warn('Traduction invalide (alt) pour', element, error);
    }
  });

  // Translate title attribute
  document.querySelectorAll('[data-i18n-title]').forEach((element) => {
    try {
      const translations = JSON.parse(element.dataset.i18nTitle);
      const text = translations[language];
      if (text !== undefined) {
        element.title = text;
      }
    } catch (error) {
      console.warn('Traduction invalide (title) pour', element, error);
    }
  });

  // Translate aria-label attribute
  document.querySelectorAll('[data-i18n-aria-label]').forEach((element) => {
    try {
      const translations = JSON.parse(element.dataset.i18nAriaLabel);
      const text = translations[language];
      if (text !== undefined) {
        element.setAttribute('aria-label', text);
      }
    } catch (error) {
      console.warn('Traduction invalide (aria-label) pour', element, error);
    }
  });

  // Translate <meta name="description"> content
  document
    .querySelectorAll('meta[name="description"][data-i18n-meta]')
    .forEach((element) => {
      try {
        const translations = JSON.parse(element.dataset.i18nMeta);
        const text = translations[language];
        if (text !== undefined) {
          element.setAttribute('content', text);
        }
      } catch (error) {
        console.warn('Traduction invalide (meta description) pour', element, error);
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
