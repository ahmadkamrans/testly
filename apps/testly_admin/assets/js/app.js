// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";

// Global
import "./modules/bootstrap";
import "./modules/theme";
import "./modules/dragula";
import "./modules/feather";
import "./modules/font-awesome";
import "./modules/moment";
import "./modules/sidebar";
import "./modules/toastr";
import "./modules/user-agent";

// Charts
import "./modules/chartjs";
import "./modules/apexcharts";

// Forms
import "./modules/daterangepicker";
import "./modules/datetimepicker";
import "./modules/fullcalendar";
import "./modules/markdown";
import "./modules/mask";
import "./modules/quill";
import "./modules/select2";
import "./modules/validation";
import "./modules/wizard";

// Maps
import "./modules/vector-maps";

// Tables
import "./modules/datatables";

import "../scss/corporate.scss";
