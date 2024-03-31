use std::os::raw::c_int;

/// # Safety
///
#[no_mangle]
pub unsafe extern "C" fn fib_row(index: *const c_int) -> *mut c_int {
    let index = *index;
    let mut row: Vec<c_int> = Vec::new();
    for i in 0..=index {
        row.push(i);
    }

    let send_pointer = row.as_mut_ptr();
    std::mem::forget(row);
    send_pointer
}
