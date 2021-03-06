const u = require('../styles/utils');
const c = require('../styles/config');
const colors = require('material-colors');

const dashboardPadding =
  25;

const halfCategorySpacing =
  10;
const categoryBorder = {
  width: 2,
  offset: 15,
};
const songHeight =
  40;
const arrowHeight =
  70;
const arrowWidth =
  20;

const transitionDuration =
  '150ms';
const transitionFunction =
  'cubic-bezier(0, 0, 0, 1)';
const foldedCategory =
  '.dashboard’s-category:not(.dashboard’s-category·unfolded)';

const arrowFilter =
  `drop-shadow(0px 0px ${u.inRem(c.displayShadowBlur / 3)} black)`;

module.exports = {
  '.dashboard': {
    'position': 'fixed',
    'z-index': `${c.zIndex.dashboard}`,
    'padding': u.inRem(dashboardPadding),
    'width': u.inRem(c.dashboardWidth),
    'height': '100%',
    'overflow-y': 'auto',
    'overflow-x': 'hidden',
  },

  '.dashboard::-webkit-scrollbar': {
    'display': 'none',
  },

  '.dashboard’s-title': {
    'font-size': u.inRem(40),
    'line-height': u.inRem(40),
  },

  '.dashboard’s-subtitle': {
    'font-size': u.inRem(12),
    'text-transform': 'uppercase',
    'letter-spacing': '0.2em',
  },

  '.dashboard’s-categories': {
    'list-style-type': 'none',
    'padding-top': u.inRem(40),
  },

  '.dashboard’s-category': {
    'line-height': u.inRem(songHeight),
    'position': 'relative',
    'margin': [
      '0',
      u.inRem(-dashboardPadding),
      u.inRem(halfCategorySpacing * 2),
      u.inRem(-dashboardPadding + categoryBorder.offset),
    ].join(' '),
  },

  '.dashboard’s-button': {
    'position': 'relative',
    'display': 'block',
    'width': '100%',
    'padding': [
      '0',
      u.inRem(dashboardPadding),
      '0',
      u.inRem(dashboardPadding - categoryBorder.width - categoryBorder.offset),
    ].join(' '),

    'color': 'inherit',
    'text-decoration': 'none',
  },

  [[
    '.dashboard’s-button',
    '.dashboard’s-button:focus',
    '.dashboard’s-button:active',
  ]]: {
    'border-left': [
      u.inRem(categoryBorder.width),
      'solid',
      u.primaryColorOpacity(0.7),
    ].join(' '),
  },

  [[
    '.dashboard’s-button::before',
    '.dashboard’s-button::after',
  ]]: {
    'content': '""',
    'display': 'block',
    'position': 'absolute',
    'top': '0',
    'right': '0',
    'bottom': '0',
    'left': '0',
    'opacity': '0',
    'z-index': '-1',
  },

  '.dashboard’s-button::before': {
    'background': u.primaryColorOpacity(0.1),
  },

  '.dashboard’s-button::after': {
    'background': u.primaryColorOpacity(0.2),
  },

  [[
    '.dashboard’s-button:hover::before',
    '.dashboard’s-button:active::after',
    '.dashboard’s-button:focus::after',
  ]]: {
    'opacity': '1',
    'background': 'transparent',
    'transition': 'background 1s cubic-bezier(0, 0, 0.4, 1)',
  },

  '.dashboard’s-button:focus': {
    'outline': 'none',
    'border-left-color': colors.cyan[600],
  },

  '.dashboard’s-category-title': {
    'line-height': u.inRem(60),
    'font-size': u.inRem(14),
    'text-transform': 'uppercase',
    'letter-spacing': '0.07em',
  },

  '.dashboard’s-song': {
    'position': 'relative',
    'display': 'block',
    'color': u.primaryColorOpacity(1),
    'transition': [
      `line-height ${transitionDuration} ${transitionFunction}`,
      `color ${transitionDuration} ${transitionFunction}`,
      `visibility ${transitionDuration} step-start`,
    ].join(', '),
  },

  [`${foldedCategory} .dashboard’s-song:not(.dashboard’s-song·current)`]: {
    'line-height': '0rem',
    'visibility': 'hidden',
    'color': u.primaryColorOpacity(0),
    'transition-timing-function': [
      transitionFunction,
      transitionFunction,
      'step-end',
    ].join(', '),
  },

  '.dashboard’s-song·current::after': {
    'right': u.inRem(-1),
    'top': u.inRem((songHeight - arrowHeight) / 2),
    'content': '""',
    'display': 'block',
    'border': `${u.inRem(arrowHeight / 2)} transparent solid`,
    'border-left-width': '0',
    'border-right': `${u.inRem(arrowWidth + 1)} black solid`,
    'position': 'absolute',
    '-webkit-filter': arrowFilter,
    'filter': arrowFilter,
  },
};
