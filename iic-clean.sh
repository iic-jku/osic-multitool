#!/bin/sh
# ========================================================================
# Cleanup of temporary files
#
# SPDX-FileCopyrightText: 2021-2023 Harald Pretl
# Johannes Kepler University, Institute for Integrated Circuits
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0
# ========================================================================

echo "[INFO] Cleaning up files (hierarchically)."

rm -rf ./*.spc
rm -rf ./*.ext
rm -rf ./*.log
rm -rf ./*.out
rm -rf ./*.raw
rm -rf ./*.spice
rm -rf ./*.vcd
rm -rf ./ext_*.tcl
rm -rf ./drc_*.tcl
rm -rf ./pex_*.tcl
