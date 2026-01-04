import { supaDB } from './db.js'
export async function listProducts(){
  const {data,error}=await supaDB.from('products').select('*').order('created_at')
  return {data,error}
}
export async function getBySlug(slug){
  const {data,error}=await supaDB.from('products').select('*').eq('slug',slug).single()
  return {data,error}
}
export async function insertProduct(p){
  return await supaDB.from('products').insert([p]).select().single()
}