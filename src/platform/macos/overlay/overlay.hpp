#pragma once

#include <memory>

#include "application/overlay.hpp"

namespace oatmeal {

std::unique_ptr<Overlay> create_overlay();

}  // namespace oatmeal
