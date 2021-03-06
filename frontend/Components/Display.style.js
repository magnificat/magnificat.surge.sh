const u = require('../styles/utils');
const c = require('../styles/config');

const grabZoneWidth = 30;
const relativeLineHeight = 1.8;
const fontToScreenWidth = 2.5;
const minFontSizeInPx = 18;
const lineContinuationIndent = 1.8;

module.exports = {
  '.display’s-wrapper': {
    'position': 'absolute',
    'top': '0',
    'width': '100%',
    'left': '0',
    'overflow-x': 'scroll',
    'min-height': '100%',
    'height': '0',
  },

  [[
    '.display’s-wrapper',
  ].map(selector => `${selector}::-webkit-scrollbar`).join(', ')]: {
    'display': 'none',
  },

  '.display': {
    'position': 'relative',
    'z-index': `${c.zIndex.display}`,
    'pointer-events': 'auto',
    'min-height': '100%',
    'width': '100%',
    'left': u.inRem(c.dashboardWidth),
    'padding': `${relativeLineHeight / 2}em`,
    'background': 'black',
    'box-shadow': [
      [
        u.inRem(c.displayShadowBlur),
        '0',
        u.inRem(c.displayShadowBlur),
        u.inRem(c.displayShadowBlur),
        'black',
      ].join(' '),
        // The shadow itself
      '999999px 0 0 999999px black',
        // Prevent subpixel rounding artifacts on edges.
    ].join(', '),
    'color': u.whiteOpacity(1),
    'line-height': `${relativeLineHeight}`,
    'font-size': `${fontToScreenWidth}vw`,
  },

  [`@media screen and (max-width: ${
    minFontSizeInPx / fontToScreenWidth * 100
  }px)`]: {
    '.display': {
      'font-size': `${minFontSizeInPx}px`,
    },
  },

  '.display::after': {
    'display': 'block',
    'content': '""',
    'position': 'absolute',
    'top': '0',
    'left': u.inRem(-grabZoneWidth),
    'bottom': '0',
    'width': u.inRem(grabZoneWidth),
  },

  '[data-fonts-loaded] .display': {
    'color': u.whiteOpacity(1),
  },

  '.display’s-song-block': {
    'margin-bottom': `${relativeLineHeight}em`,
  },

  '.display’s-song-block·type»refrain': {
    'font-style': 'italic',
  },

  '.display’s-song-line': {
    'padding-left': `${lineContinuationIndent}em`,
    'text-indent': `${-lineContinuationIndent}em`,
  },
};
