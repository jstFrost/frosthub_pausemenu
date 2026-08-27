const base = {
  viewBox: '0 0 24 24',
  fill: 'none',
  stroke: 'currentColor',
  strokeWidth: 1.7,
  strokeLinecap: 'round',
  strokeLinejoin: 'round',
  xmlns: 'http://www.w3.org/2000/svg',
}

export const IconHome = (p) => (
  <svg {...base} {...p}><path d="M4 10.5 12 4l8 6.5V20H4z" /><path d="M9.5 20v-5.5h5V20" /></svg>
)

export const IconMap = (p) => (
  <svg {...base} {...p}><path d="M9 4 3.5 6.2v13.6L9 17.6l6 2.2 5.5-2.2V4L15 6.2z" /><path d="M9 4v13.6M15 6.2V19.8" /></svg>
)

export const IconSettings = (p) => (
  <svg {...base} {...p}><circle cx="12" cy="12" r="3" /><path d="M12 3.5v2.2M12 18.3v2.2M20.5 12h-2.2M5.7 12H3.5M18 6l-1.6 1.6M7.6 16.4 6 18M18 18l-1.6-1.6M7.6 7.6 6 6" /></svg>
)

export const IconExit = (p) => (
  <svg {...base} {...p}><path d="M14 4.5H6.5v15H14" /><path d="M11 12h9.5M17 8.5l3.5 3.5-3.5 3.5" /></svg>
)

export const IconPin = (p) => (
  <svg {...base} {...p}><path d="M12 21s6.5-6.1 6.5-10.5a6.5 6.5 0 1 0-13 0C5.5 14.9 12 21 12 21z" /><circle cx="12" cy="10.5" r="2.3" /></svg>
)

export const IconDiscord = (p) => (
  <svg viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg" {...p}>
    <path d="M19.3 5.4A16.9 16.9 0 0 0 15.1 4l-.2.4a12.6 12.6 0 0 1 3.7 1.9 13.3 13.3 0 0 0-11.3 0A12.7 12.7 0 0 1 11 4.4L10.8 4a16.9 16.9 0 0 0-4.2 1.4C4 9.3 3.3 13.1 3.6 16.8A16.9 16.9 0 0 0 8.8 19l1-1.4a10.9 10.9 0 0 1-1.7-.8l.4-.3a12.1 12.1 0 0 0 10.9 0l.4.3a11 11 0 0 1-1.7.8l1 1.4a16.8 16.8 0 0 0 5.2-2.2c.4-4.3-.6-8.1-3-11.4zM9.5 14.6c-1 0-1.9-.9-1.9-2.1s.8-2.1 1.9-2.1 1.9 1 1.9 2.1-.8 2.1-1.9 2.1zm5 0c-1 0-1.9-.9-1.9-2.1s.8-2.1 1.9-2.1 1.9 1 1.9 2.1-.8 2.1-1.9 2.1z" />
  </svg>
)

export const IconStore = (p) => (
  <svg {...base} {...p}><path d="M4 8.5h16l-1 11H5z" /><path d="M8.5 8.5V6.8a3.5 3.5 0 0 1 7 0v1.7" /></svg>
)
