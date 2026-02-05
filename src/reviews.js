import { supaDB } from './db.js'
export async function getProductReviews(productId) {
  return await supaDB.from('reviews').select('*, profiles(full_name)').eq('product_id', productId).order('created_at', {ascending:false})
}
export async function addReview(userId, productId, rating, comment) {
  return await supaDB.from('reviews').insert({user_id: userId, product_id: productId, rating, comment})
}