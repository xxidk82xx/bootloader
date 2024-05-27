use std::{env, fs::{read, read_dir, File}, io::{Seek, SeekFrom}, path::{self, Path}};
fn main() {
    let args: Vec<String> = env::args().collect();
    println!("reading stage1");
    let stage1 = read(Path::new("../loader/build/stage1/stage1.bin")).expect("cannot find stage1 bin file");
    println!("copying boot sector into drive");
    let mut drive = File::open(parse_drive(args).expect("please input a file to write to")).expect("cannot open file");
    let seek = SeekFrom::Start(0);
}

fn parse_drive(args: Vec<String>)  -> Option<String>{
    let mut buff = None;
    for str in args {
        if str.starts_with("--disk_dir") { 
            str.strip_prefix("--disk_dir=")
        }
        else {
            None
        };
    }
    buff
}

fn get_funcs() {

}
