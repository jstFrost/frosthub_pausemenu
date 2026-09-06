export function formatMoney(amount, currency) {
  const value = Number(amount) || 0
  const { locale = 'en-US', symbol = '$', decimals = 2 } = currency || {}

  return symbol + value.toLocaleString(locale, {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  })
}
