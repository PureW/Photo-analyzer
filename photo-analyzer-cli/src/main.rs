use std::path::PathBuf;

use photo_analyzer::{classify_image, load_weights, new_var_store};

use structopt::StructOpt;

/// Photo-analyzer cli
#[derive(StructOpt, Debug)]
struct Opt {
    /// Weights to use
    #[structopt(long, default_value = "data/inception-v3.ot")]
    weights: PathBuf,

    /// Images to process
    #[structopt(name = "FILE", parse(from_os_str))]
    images: Vec<PathBuf>,
}

fn run(opts: Opt) -> Result<(), String> {
    let Opt { weights, images } = opts;
    let mut var_store = new_var_store();
    let net = load_weights(&mut var_store, &weights)?;
    for image in images {
        if !image.is_file() {
            continue;
        }
        println!("Starting to analyze {:?}", image.file_name());
        let classes = classify_image(&image, &net)?;
        for class in classes {
            if class.probability > 0.2 {
                let short_class = if let Some(first_word) = class.class.split(',').next() {
                    first_word
                } else {
                    &class.class
                };

                println!(
                    "    {:20}      {:5.2}%",
                    short_class,
                    class.probability * 100.
                );
            }
        }
    }
    Ok(())
}

fn main() {
    let opt = Opt::from_args();
    if let Err(err) = run(opt) {
        println!("ERROR: {:#?}", err);
        std::process::exit(1);
    }
}
