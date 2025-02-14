import { createDojoConfig } from "@dojoengine/core";
 
import manifest from "./../engine/manifest_dev.json"
 
export const dojoConfig = createDojoConfig({
    manifest
});