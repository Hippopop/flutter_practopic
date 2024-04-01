use std::os::raw::c_int;

/// # Safety
///
#[no_mangle]
pub unsafe extern "C" fn fib_row(index: *const c_int) -> *mut c_int {
    let index = *index;
    let mut row: Vec<c_int> = Vec::new();
    for i in 1..=index {
        row.push(unsafe { slow_fib(i) });
    }

    let send_pointer = row.as_mut_ptr();
    std::mem::forget(row);
    send_pointer
}

/// # Safety
///
#[no_mangle]
pub unsafe extern "C" fn slow_fib(i: c_int) -> c_int {
    let n = i;
    if n <= 1 {
        return n;
    }

    slow_fib(n - 1) + slow_fib(n - 2)
}
