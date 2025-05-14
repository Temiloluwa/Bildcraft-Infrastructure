module "image_translation_s3" {
  source       = "./modules/s3"
  project_code = "blc"
  prefix       = "image-translation"
  context      = module.global.context
}