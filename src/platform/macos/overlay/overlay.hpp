#pragma once

#include "application/overlay.hpp"

#include <memory>

namespace oatmeal {

std::unique_ptr<Overlay> create_overlay();

} // namespace oatmeal
