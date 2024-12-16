const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {

    const target = b.standardTargetOptions(.{});
    const option = b.standardOptimizeOption(.{});

    const plutovg = build_plutovg(b, target, option, "");
    const plutosvg = build_plutosvg(b, target, option, plutovg, "");
    _ = build_zplutosvg(b, target, option, plutovg, plutosvg, "");

}

pub fn build_plutovg(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    mode: std.builtin.OptimizeMode,
    comptime prefix_path: []const u8,
) *std.Build.Step.Compile {
    const flags = [_][]const u8{
        "-DPLUTOVG_BUILD_STATIC",
    };

    const dir = prefix_path ++ "plutovg/";

    const sources = [_][]const u8{
        "source/plutovg-canvas.c",
        "source/plutovg-font.c",
        "source/plutovg-ft-math.c",
        "source/plutovg-ft-raster.c",
        "source/plutovg-ft-stroker.c",
        "source/plutovg-matrix.c",
        "source/plutovg-paint.c",
        "source/plutovg-path.c",
        "source/plutovg-rasterize.c",
        "source/plutovg-surface.c",
        "source/plutovg-blend.c",
    };

    const incl_dirs = [_][]const u8{
        "source",
        "include",
    };

    const lib = b.addStaticLibrary(.{
        .name = "plutovg",
        .target = target,
        .optimize = mode,
    });

    inline for (incl_dirs) |incl_dir| {
        lib.addIncludePath(b.path(dir ++ incl_dir));
    }

    inline for (sources) |src| {
        lib.addCSourceFile(.{ .file = b.path(dir ++ src), .flags = &flags });
    }

    lib.linkSystemLibrary("m");
    lib.linkLibC();
    //lib.linkLibCpp();

    b.installArtifact(lib);

    return lib;
}

pub fn build_plutosvg(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    mode: std.builtin.OptimizeMode,
    pluto: *std.Build.Step.Compile,
    comptime prefix_path: []const u8,
) *std.Build.Step.Compile {
    const flags = [_][]const u8{
        "-DPLUTOVG_BUILD_STATIC",
        "-DPLUTOSVG_BUILD_STATIC",
    };

    const dir = prefix_path ++ "";

    const sources = [_][]const u8{
        "plutosvg/source/plutosvg.c",
    };

    const incl_dirs = [_][]const u8{
        "plutosvg/source",
        "plutovg/include",
    };

    const lib = b.addStaticLibrary(.{
        .name = "plutosvg",
        .target = target,
        .optimize = mode,
    });

    lib.linkLibrary(pluto);

    inline for (incl_dirs) |incl_dir| {
        lib.addIncludePath(b.path(dir ++ incl_dir));
    }

    inline for (sources) |src| {
        lib.addCSourceFile(.{ .file = b.path(dir ++ src), .flags = &flags });
    }

    lib.linkLibC();

    b.installArtifact(lib);

    return lib;
}

// pub fn build_lunasvg(
//     b: *std.Build,
//     target: std.Build.ResolvedTarget,
//     mode: std.builtin.OptimizeMode,
//     pluto: *std.Build.Step.Compile,
//     comptime prefix_path: []const u8,
// ) *std.Build.Step.Compile {
//     const flags = [_][]const u8{
//         "-DPLUTOVG_BUILD_STATIC",
//         "-DLUNASVG_BUILD_STATIC",
//     };

//     const dir = prefix_path ++ "";

//     const sources = [_][]const u8{
//         "lunasvg/source/svgelement.cpp",
//         "lunasvg/source/svggeometryelement.cpp",
//         "lunasvg/source/svglayoutstate.cpp",
//         "lunasvg/source/svgpaintelement.cpp",
//         "lunasvg/source/svgparser.cpp",
//         "lunasvg/source/svgproperty.cpp",
//         "lunasvg/source/svgrenderstate.cpp",
//         "lunasvg/source/svgtextelement.cpp",
//         "lunasvg/source/graphics.cpp",
//         "lunasvg/source/lunasvg.cpp",
//     };

//     const incl_dirs = [_][]const u8{
//         "lunasvg/include",
//         "plutovg/include",
//     };

//     const lib = b.addStaticLibrary(.{
//         .name = "lunasvg",
//         .target = target,
//         .optimize = mode,
//     });

//     lib.linkLibrary(pluto);

//     inline for (incl_dirs) |incl_dir| {
//         lib.addIncludePath(b.path(dir ++ incl_dir));
//     }

//     inline for (sources) |src| {
//         lib.addCSourceFile(.{ .file = b.path(dir ++ src), .flags = &flags });
//     }

//     //lib.linkLibC();
//     lib.linkLibCpp();

//     b.installArtifact(lib);

//     return lib;
// }

// pub fn build_svg2png(
//     b: *std.Build,
//     target: std.Build.ResolvedTarget,
//     mode: std.builtin.OptimizeMode,
//     pluto: *std.Build.Step.Compile,
//     lunasvg: *std.Build.Step.Compile,
//     comptime prefix_path: []const u8,
// ) *std.Build.Step.Compile {
//     const flags = [_][]const u8{
//         "-DPLUTOVG_BUILD_STATIC",
//         "-DLUNASVG_BUILD_STATIC",
//     };

//     const dir = prefix_path ++ "";

//     const sources = [_][]const u8{
//         "lunasvg/examples/svg2png.cpp",
//     };

//     const incl_dirs = [_][]const u8{
//         "lunasvg/include",
//         "plutovg/include",
//     };

//     const exe = b.addExecutable(.{
//         .name = "svg2png",
//         .target = target,
//         .optimize = mode,
//     });

//     exe.linkLibrary(lunasvg);
//     exe.linkLibrary(pluto);

//     inline for (incl_dirs) |incl_dir| {
//         exe.addIncludePath(b.path(dir ++ incl_dir));
//     }

//     inline for (sources) |src| {
//         exe.addCSourceFile(.{ .file = b.path(dir ++ src), .flags = &flags });
//     }

//     exe.linkLibCpp();
//     //exe.linkLibC();

//     b.installArtifact(exe);

//     return exe;
// }

pub fn build_zplutosvg(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    mode: std.builtin.OptimizeMode,
    plutovg: *std.Build.Step.Compile,
    plutosvg: *std.Build.Step.Compile,
    comptime prefix_path: []const u8,
) *std.Build.Module {
    const flags = [_][]const u8{
        "-DPLUTOVG_BUILD_STATIC",
        "-DPLUTOSVG_BUILD_STATIC",
    };

    const dir = prefix_path ++ "";

    const sources = [_][]const u8{
        //"src/lunasvg_glue.cpp",
    };

    const incl_dirs = [_][]const u8{
        "plutosvg/source",
        "plutovg/include",
    };

    const lib = b.addModule("zplutosvg",.{
        .target = target,
        .root_source_file = b.path("src/root.zig"),
        .optimize = mode,
        .link_libc = true,
    });



    inline for (incl_dirs) |incl_dir| {
        lib.addIncludePath(b.path(dir ++ incl_dir));
    }

    inline for (sources) |src| {
        lib.addCSourceFile(.{ .file = b.path(dir ++ src), .flags = &flags });
    }

    lib.linkLibrary(plutovg);
    lib.linkLibrary(plutosvg);
    //lib.linkLibC();


    return lib;
}
