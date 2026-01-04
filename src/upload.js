import { supaDB } from './db.js'
export async function uploadFile(file){
  const fileName = `${crypto.randomUUID()}.${file.name.split('.').pop()}`
  const {data, error} = await supaDB.storage.from('models').upload(fileName, file)
  if(error) return {error}
  const url = supaDB.storage.from('models').getPublicUrl(fileName).data.publicUrl
  return {url, error:null}
}