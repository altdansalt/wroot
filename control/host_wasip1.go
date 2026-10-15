//go:build wasip1

package main

import (
	"encoding/json"
	"fmt"
	"unsafe"
)

// Host imports provided by wasmdev-host (module "wasmdev"); see
// docs/HOST_CAPABILITIES.md. All are non-blocking.

//go:wasmimport wasmdev exec_start
func hostExecStart(spec unsafe.Pointer, specLen uint32) int64

//go:wasmimport wasmdev exec_status
func hostExecStatus(handle int64, buf unsafe.Pointer, bufCap uint32) int32

//go:wasmimport wasmdev exec_kill
func hostExecKill(handle int64) int32

//go:wasmimport wasmdev exec_release
func hostExecRelease(handle int64) int32

type hostImpl struct{}

func (hostImpl) Start(spec *ExecSpec) (int64, error) {
	b, err := json.Marshal(spec)
	if err != nil {
		return 0, err
	}
	return hostExecStart(unsafe.Pointer(unsafe.SliceData(b)), uint32(len(b))), nil
}

func (hostImpl) Status(h int64) (*ExecStatus, error) {
	buf := make([]byte, 512)
	for {
		n := hostExecStatus(h, unsafe.Pointer(unsafe.SliceData(buf)), uint32(len(buf)))
		if n < 0 {
			return nil, fmt.Errorf("unknown exec handle %d", h)
		}
		if int(n) <= len(buf) {
			var st ExecStatus
			if err := json.Unmarshal(buf[:n], &st); err != nil {
				return nil, err
			}
			return &st, nil
		}
		buf = make([]byte, n)
	}
}

func (hostImpl) Kill(h int64) bool    { return hostExecKill(h) == 0 }
func (hostImpl) Release(h int64) bool { return hostExecRelease(h) == 0 }
