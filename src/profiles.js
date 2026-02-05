import { supaDB } from './db.js'
export async function getProfile(userId) {
  const {data,error} = await supaDB.from('profiles').select('*').eq('id', userId).single()
  return {data,error}
}
export async function updateProfile(userId, fields) {
  return await supaDB.from('profiles').upsert({id: userId, ...fields})
}