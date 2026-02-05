import { supaDB } from './db.js'
export async function validatePromo(code) {
  const {data,error} = await supaDB.from('promos').select('*')
    .eq('code', code.toUpperCase())
    .gt('valid_until', new Date().toISOString())
    .single()
  if(error) return {valid:false, error:'Invalid code'}
  if(data.max_uses && data.used_count >= data.max_uses) return {valid:false, error:'Code expired'}
  return {valid:true, data}
}