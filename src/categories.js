import { supaDB } from './db.js'
export async function listCategories() {
  return await supaDB.from('categories').select('*').is('parent_id', null)
}
export async function getCategoryBySlug(slug) {
  return await supaDB.from('categories').select('*').eq('slug', slug).single()
}