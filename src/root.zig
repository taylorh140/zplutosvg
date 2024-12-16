const std = @import("std");
const svg = @cImport({
    @cInclude("plutosvg.h");
    @cInclude("plutovg.h");
});

pub const image_t = struct {
    width: usize,
    height: usize,
    data: []const u32, //ARGB
};

const surface_t = extern struct {
    ref_count: c_int,
    width: c_int,
    height: c_int,
    stride: c_int,
    data: *u8,
};

pub const RenderError = error{
    CouldNotGenerateDocument,
    CouldNotRenderDocument,
};

pub fn RenderSvg(SvgString: []const u8, allocator: *const std.mem.Allocator) !image_t {
    const document = svg.plutosvg_document_load_from_data(SvgString.ptr, @intCast(SvgString.len), -1, -1, null, null);
    defer svg.plutosvg_document_destroy(document);

    if (document == null) return RenderError.CouldNotGenerateDocument;
    const doc = document.?;

    const surfaceQ = svg.plutosvg_document_render_to_surface(doc, null, -1, -1, null, null, null);
    defer svg.plutovg_surface_destroy(surfaceQ);
    if (surfaceQ == null) return RenderError.CouldNotRenderDocument;

    const surface: *surface_t = @alignCast(@ptrCast(surfaceQ.?));

    var imageData = try allocator.alloc(u32, @intCast(surface.width * surface.height));
    const renderedData: []u32 = @as([*]u32, @ptrCast(&surface.data))[0..@intCast(surface.width * surface.height)];

    @memcpy(imageData, renderedData);

    const image = image_t{
        .data = imageData[0..],
        .height = @intCast(surface.height),
        .width = @intCast(surface.width),
    };

    // std.debug.print("{any}\n", .{image});

    // _ = svg.plutovg_surface_write_to_png(surfaceQ, "out.png");

    return image;
}
