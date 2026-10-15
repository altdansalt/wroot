//go:build !wasip1

package main

import "errors"

// Stub so the package type-checks / unit-tests natively. The real service
// only runs as wasip1 under wasmdev-host.
type hostImpl struct{}

var errNoHost = errors.New("wasmdev host imports are only available under wasmdev-host (wasip1)")

func (hostImpl) Start(*ExecSpec) (int64, error)    { return 0, errNoHost }
func (hostImpl) Status(int64) (*ExecStatus, error) { return nil, errNoHost }
func (hostImpl) Kill(int64) bool                   { return false }
func (hostImpl) Release(int64) bool                { return false }
func (hostImpl) Ready(int64) int                   { return -1 }
