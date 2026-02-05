import { supaDB } from './db.js'
export async function getWishlist(userId) {
  return await supaDB.from('wishlists').select('*, products(*)').eq('user_id', userId)
}
export async function toggleWishlist(userId, productId) {
  const {data:existing} = await supaDB.from('wishlists').select('*')
    .eq('user_id', userId).eq('product_id', productId).single()
  if(existing) {
    return await supaDB.from('wishlists').delete().eq('id', existing.id)
  } else {
    return await supaDB.from('wishlists').insert({user_id: userId, product_id: productId})
  }
}