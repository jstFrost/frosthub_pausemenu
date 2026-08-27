// Must match the `name` field in fxmanifest.lua.
const RESOURCE_NAME = 'frosthub_pausemenu'

export async function callNui(action, payload = {}) {
  try {
    const response = await fetch(`https://${RESOURCE_NAME}/${action}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(payload),
    })

    if (!response.ok) throw new Error(`NUI call "${action}" failed: ${response.status}`)

    const contentType = response.headers.get('content-type') || ''
    return contentType.includes('application/json') ? await response.json() : await response.text()
  } catch (error) {
    console.warn(`[frosthub_pausemenu] ${action} ->`, error.message)
    return null
  }
}
