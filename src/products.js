import { supaDB } from './db.js'

export async function listProducts() {
  const { data, error } = await supaDB.from('products').select('*').order('created_at', { ascending: false })
  return { data, error }
}

export async function getBySlug(slug) {
  const { data, error } = await supaDB.from('products').select('*').eq('slug', slug).single()
  return { data, error }
}

export async function insertProduct(p) {
  const { data, error } = await supaDB.from('products').insert([p]).select().single()
  return { data, error }
}

export async function deleteProduct(productId) {
  const { data, error } = await supaDB.from('products').delete().eq('id', productId)
  return { data, error }
}

export async function updateProduct(productId, updates) {
  const { data, error } = await supaDB.from('products').update(updates).eq('id', productId).select().single()
  return { data, error }
}