import { supaDB } from './db.js'
export async function getProductVariants(productId) {
  return await supaDB.from('variants').select('*').eq('product_id', productId)
}