import { supaDB } from './db.js'

export async function uploadFile(file) {
  const fileName = `${crypto.randomUUID()}.${file.name.split('.').pop()}`
  
  // Upload to 'models' bucket
  const { data, error } = await supaDB.storage.from('models').upload(fileName, file)
  if (error) return { error }
  
  // Get public URL
  const { data: { publicUrl } } = supaDB.storage.from('models').getPublicUrl(fileName)
  return { url: publicUrl, error: null }
}