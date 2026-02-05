import { supaDB } from './db.js'

export async function loadCart(userId) {
  const { data, error } = await supaDB
    .from('cart_items')
    .select('*, products(*)')
    .eq('user_id', userId)
  return { data, error }
}

export async function addToCart(userId, productId, qty = 1) {
  const { data, error } = await supaDB.from('cart_items').upsert(
    { user_id: userId, product_id: productId, qty },
    { onConflict: 'user_id,product_id' }
  )
  return { data, error }
}

export async function removeFromCart(itemId) {
  return await supaDB.from('cart_items').delete().eq('id', itemId)
}

export async function clearCart(userId) {
  return await supaDB.from('cart_items').delete().eq('user_id', userId)
}